local quiet_nesting = true

local function define_leafdiff_hl()
  local ok, colors = pcall(function()
    return require("base46").get_theme_tb "base_16"
  end)
  colors = ok and colors or {}
  vim.api.nvim_set_hl(0, "LeafDiffNew", { fg = colors.base0B or "#365A1E", bold = true })
  vim.api.nvim_set_hl(0, "LeafDiffMod", { fg = colors.base0D or "#325666", bold = true })
  vim.api.nvim_set_hl(0, "LeafDiffDel", { fg = colors.base08 or "#943528", bold = true })
end

define_leafdiff_hl()
vim.api.nvim_create_autocmd("ColorScheme", { callback = define_leafdiff_hl })

local function alnum(s)
  return (s:lower():gsub("[^%w]", ""))
end

local function normalize(text)
  text = text:gsub("^~~(.-)~~$", "%1")
  text = text:lower():gsub("%s+", " ")
  return vim.trim(text)
end

local function leaves(lines, tab)
  local entries, stack, fenced = {}, {}, false
  for lnum, line in ipairs(lines) do
    if line:match "^%s*```" or line:match "^%s*~~~" then
      fenced = not fenced
    elseif not fenced then
      local text = line:match "^%s*[%*%-%+]%s+(.-)%s*$" or line:match "^%s*%d+[.)]%s+(.-)%s*$"
      if text then
        local width = 0
        for ch in line:match("^%s*"):gmatch "." do
          width = ch == "\t" and width + tab - (width % tab) or width + 1
        end
        while #stack > 0 and stack[#stack].indent >= width do
          table.remove(stack)
        end
        local parents, pnorm = {}, {}
        for _, p in ipairs(stack) do
          table.insert(parents, p.text)
          table.insert(pnorm, alnum(p.text))
        end
        table.insert(stack, { indent = width, text = text })
        table.insert(entries, {
          indent = width,
          text = text,
          norm = normalize(text),
          lnum = lnum,
          parents = parents,
          pnorm = pnorm,
        })
      end
    end
  end
  local result, parent_set = {}, {}
  for i, e in ipairs(entries) do
    local nxt = entries[i + 1]
    if not nxt or nxt.indent <= e.indent then
      table.insert(result, e)
    else
      parent_set[e.norm] = true
    end
  end
  return result, parent_set
end

local function lev(a, b)
  local prev = {}
  for j = 0, #b do
    prev[j] = j
  end
  for i = 1, #a do
    local cur = { [0] = i }
    for j = 1, #b do
      local cost = a:byte(i) == b:byte(j) and 0 or 1
      cur[j] = math.min(prev[j] + 1, cur[j - 1] + 1, prev[j - 1] + cost)
    end
    prev = cur
  end
  return prev[#b]
end

local function word_sim(a, b)
  local ta, tb = {}, {}
  for w in a:gmatch "%w+" do
    ta[#ta + 1] = w
  end
  for w in b:gmatch "%w+" do
    tb[#tb + 1] = w
  end
  if #ta == 0 or #tb == 0 then
    return 0
  end
  local used, matched = {}, 0
  for _, x in ipairs(ta) do
    for j, y in ipairs(tb) do
      if not used[j] and (x == y or (#x >= 4 and #y >= 4 and lev(x, y) <= 1)) then
        used[j] = true
        matched = matched + 1
        break
      end
    end
  end
  local p, r = matched / #ta, matched / #tb
  return p + r == 0 and 0 or 2 * p * r / (p + r)
end

local function similarity(a, b)
  local char = 1 - lev(a, b) / math.max(#a, #b, 1)
  return math.max(word_sim(a, b), char)
end

local function pair_edits(missing, added)
  local scored = {}
  for i, m in ipairs(missing) do
    for j, a in ipairs(added) do
      local s = similarity(m.norm, a.norm)
      if table.concat(m.pnorm, "\0") == table.concat(a.pnorm, "\0") then
        s = s + 0.05
      end
      if s >= 0.65 then
        scored[#scored + 1] = { i = i, j = j, s = s }
      end
    end
  end
  table.sort(scored, function(x, y)
    return x.s > y.s
  end)
  local used_m, used_a, pairs_out = {}, {}, {}
  for _, p in ipairs(scored) do
    if not used_m[p.i] and not used_a[p.j] then
      used_m[p.i], used_a[p.j] = true, true
      pairs_out[#pairs_out + 1] = { old = missing[p.i], new = added[p.j] }
    end
  end
  local rest_m, rest_a = {}, {}
  for i, m in ipairs(missing) do
    if not used_m[i] then
      rest_m[#rest_m + 1] = m
    end
  end
  for j, a in ipairs(added) do
    if not used_a[j] then
      rest_a[#rest_a + 1] = a
    end
  end
  return pairs_out, rest_m, rest_a
end

local function is_prefix(a, b)
  if #a > #b then
    a, b = b, a
  end
  for i = 1, #a do
    if a[i] ~= b[i] then
      return false
    end
  end
  return true
end

local function match_same_text(before, after)
  local exact = {}
  for j, a in ipairs(after) do
    local k = a.norm .. "\1" .. table.concat(a.pnorm, "\0")
    exact[k] = exact[k] or {}
    table.insert(exact[k], j)
  end
  local used_b, used_a = {}, {}
  for i, b in ipairs(before) do
    local q = exact[b.norm .. "\1" .. table.concat(b.pnorm, "\0")]
    if q and #q > 0 then
      used_b[i] = true
      used_a[table.remove(q, 1)] = true
    end
  end
  local by_norm = {}
  for j, a in ipairs(after) do
    if not used_a[j] then
      by_norm[a.norm] = by_norm[a.norm] or {}
      table.insert(by_norm[a.norm], j)
    end
  end
  local moved = {}
  for i, b in ipairs(before) do
    if not used_b[i] then
      local q = by_norm[b.norm]
      if q and #q > 0 then
        local j = table.remove(q, 1)
        used_b[i], used_a[j] = true, true
        local a = after[j]
        local nesting = is_prefix(b.pnorm, a.pnorm)
        if not (quiet_nesting and nesting) then
          moved[#moved + 1] = { old = b, new = a }
        end
      end
    end
  end
  local rest_b, rest_a = {}, {}
  for i, b in ipairs(before) do
    if not used_b[i] then
      rest_b[#rest_b + 1] = b
    end
  end
  for j, a in ipairs(after) do
    if not used_a[j] then
      rest_a[#rest_a + 1] = a
    end
  end
  return moved, rest_b, rest_a
end

local function path_of(e)
  return #e.parents > 0 and table.concat(e.parents, "::") .. "::" or ""
end

vim.api.nvim_create_user_command("LeafDiff", function(opts)
  local rev = opts.args ~= "" and opts.args or "HEAD"
  local buf = vim.api.nvim_get_current_buf()
  local file = vim.api.nvim_buf_get_name(buf)
  local dir = vim.fn.fnamemodify(file, ":h")
  local old = vim.fn.systemlist { "git", "-C", dir, "show", rev .. ":./" .. vim.fn.fnamemodify(file, ":t") }
  if vim.v.shell_error ~= 0 then
    vim.notify("LeafDiff: could not read " .. rev .. " version: " .. table.concat(old, " "), vim.log.levels.ERROR)
    return
  end
  local tab = vim.bo[buf].tabstop
  local before_all, before_parents = leaves(old, tab)
  local after_all, after_parents = leaves(vim.api.nvim_buf_get_lines(buf, 0, -1, false), tab)
  local before, after = {}, {}
  for _, e in ipairs(before_all) do
    if not after_parents[e.norm] then
      table.insert(before, e)
    end
  end
  for _, e in ipairs(after_all) do
    if not before_parents[e.norm] then
      table.insert(after, e)
    end
  end
  local mods, rest_b, rest_a = match_same_text(before, after)
  local edited
  edited, rest_b, rest_a = pair_edits(rest_b, rest_a)
  for _, p in ipairs(edited) do
    table.insert(mods, p)
  end
  print(("[%d -> %d] %d MOD, %d DEL, %d NEW (vs %s)"):format(#before, #after, #mods, #rest_b, #rest_a, rev))
  if #mods == 0 and #rest_b == 0 and #rest_a == 0 then
    return
  end
  local oldbuf
  if #rest_b > 0 then
    local tail = vim.fn.fnamemodify(file, ":t")
    local full = dir .. "/" .. tail .. "@" .. rev
    for _, b in ipairs(vim.api.nvim_list_bufs()) do
      if vim.api.nvim_buf_get_name(b) == full then
        vim.api.nvim_buf_delete(b, { force = true })
      end
    end
    oldbuf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(oldbuf, 0, -1, false, old)
    vim.api.nvim_buf_set_name(oldbuf, full)
    vim.bo[oldbuf].filetype = "markdown"
    vim.bo[oldbuf].modifiable = false
  end
  local items = {}
  for _, p in ipairs(mods) do
    table.insert(items, {
      bufnr = buf,
      lnum = p.new.lnum,
      col = 1,
      text = ("MOD  %s%s  ->  %s%s"):format(path_of(p.old), p.old.text, path_of(p.new), p.new.text),
    })
  end
  for _, e in ipairs(rest_b) do
    table.insert(items, { bufnr = oldbuf, lnum = e.lnum, col = 1, text = "DEL  " .. path_of(e) .. e.text })
  end
  for _, e in ipairs(rest_a) do
    table.insert(items, { bufnr = buf, lnum = e.lnum, col = 1, text = "NEW  " .. path_of(e) .. e.text })
  end
  local hash = vim.fn.systemlist({ "git", "-C", dir, "rev-parse", "--short", rev })[1]
  if vim.v.shell_error ~= 0 or not hash or hash == "" then
    hash = rev
  end
  local function format(info)
    local list = vim.fn.getqflist({ id = info.id, items = 1 }).items
    local name_w, line_w = #"now", 1
    for i = info.start_idx, info.end_idx do
      line_w = math.max(line_w, #tostring(list[i].lnum))
    end
    name_w = math.max(name_w, #hash)
    local out = {}
    for i = info.start_idx, info.end_idx do
      local it = list[i]
      local name = it.bufnr == oldbuf and hash or "now"
      out[#out + 1] = ("%-" .. name_w .. "s|%" .. line_w .. "d col %d| %s"):format(name, it.lnum, it.col, it.text)
    end
    return out
  end
  vim.fn.setqflist({}, " ", { title = "LeafDiff vs " .. rev, items = items, quickfixtextfunc = format })
  vim.cmd "copen"
  for _, m in ipairs(vim.fn.getmatches()) do
    if m.group:match "^LeafDiff" then
      vim.fn.matchdelete(m.id)
    end
  end
  vim.fn.matchadd("LeafDiffNew", [[^.\{-}col \d\+|\s*\zsNEW\ze\s]])
  vim.fn.matchadd("LeafDiffMod", [[^.\{-}col \d\+|\s*\zsMOD\ze\s]])
  vim.fn.matchadd("LeafDiffDel", [[^.\{-}col \d\+|\s*\zsDEL\ze\s]])
end, { nargs = "?", desc = "Compare leaf list items against a git revision" })

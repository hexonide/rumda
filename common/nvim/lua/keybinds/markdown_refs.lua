-- markdown list reference construction / searching
local function list_item_text(lnum)
  local line = vim.fn.getline(lnum)
  return line:match "^%s*[%*%-%+]%s+(.-)%s*$" or line:match "^%s*%d+[.)]%s+(.-)%s*$"
end

local function buf_indent(buf, line)
  local ws = line:match "^%s*"
  local width = 0
  local tab = vim.bo[buf].tabstop
  for ch in ws:gmatch "." do
    if ch == "\t" then
      width = width + tab - (width % tab)
    else
      width = width + 1
    end
  end
  return width
end

local function item_of_line(line)
  return line:match "^%s*[%*%-%+]%s+(.-)%s*$" or line:match "^%s*%d+[.)]%s+(.-)%s*$"
end

local function find_scope(buf, segments, prefix_last)
  local stack = {}
  local fenced = false
  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  for lnum, line in ipairs(lines) do
    if line:match "^%s*```" or line:match "^%s*~~~" then
      fenced = not fenced
    elseif not fenced then
      local text = item_of_line(line)
      if text then
        text = (text:gsub("^~~(.-)~~$", "%1"))
      end
      if text then
        local indent = buf_indent(buf, line)
        while #stack > 0 and stack[#stack].indent >= indent do
          table.remove(stack)
        end
        table.insert(stack, { indent = indent, text = (text:gsub("%s+", "_")), raw = text })
        if #stack >= #segments then
          local ok = true
          for k = 1, #segments do
            local entry = stack[#stack - #segments + k]
            local want = segments[k]
            if k == #segments then
              if prefix_last then
                ok = entry.raw:sub(1, #want) == want
              else
                ok = entry.raw == want or entry.text == want
              end
            else
              ok = entry.text == want
            end
            if not ok then
              break
            end
          end
          if ok then
            return lnum
          end
        end
      end
    end
  end
end

local function search_buffers(segments, prefix_last)
  local current = vim.api.nvim_get_current_buf()
  local order = { current }
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if buf ~= current and vim.bo[buf].buflisted and vim.api.nvim_buf_get_name(buf):match "%.md$" then
      if not vim.api.nvim_buf_is_loaded(buf) then
        vim.fn.bufload(buf)
      end
      table.insert(order, buf)
    end
  end
  for _, buf in ipairs(order) do
    local lnum = find_scope(buf, segments, prefix_last)
    if lnum then
      return buf, lnum
    end
  end
end

local ref_pattern = "[%w_%-]+::[%w_%-:]*[%w_%-]"

local function parse_refs(line)
  local refs = {}
  local body_start = line:match "^%s*[%*%-%+]%s+()" or line:match "^%s*%d+[.)]%s+()"
  if body_start and line:sub(body_start, body_start + 1) == "~~" then
    body_start = body_start + 2
  end
  local init = 1
  while true do
    local s, e = line:find(ref_pattern, init)
    if not s then
      break
    end
    local tail_end = e
    if body_start == s then
      local trimmed = line:gsub("%s+$", "")
      trimmed = trimmed:gsub("~~$", "")
      tail_end = #trimmed
    end
    local segments, starts = {}, {}
    local pos = s
    for seg in line:sub(s, e):gmatch "[^:]+" do
      table.insert(segments, seg)
      table.insert(starts, pos)
      pos = pos + #seg + 2
    end
    local candidates = {}
    local rest = vim.trim(line:sub(starts[#starts]))
    rest = vim.trim(rest:gsub("~~%s*$", ""))
    local words = vim.split(rest, "%s+")
    for n = #words, 1, -1 do
      table.insert(candidates, table.concat(words, " ", 1, n))
    end
    if candidates[#candidates] ~= segments[#segments] then
      table.insert(candidates, segments[#segments])
    end
    table.insert(refs, { s = s, e = tail_end, segments = segments, starts = starts, candidates = candidates })
    init = math.max(e, tail_end) + 1
  end
  return refs
end

local function scope_at_cursor()
  local line = vim.api.nvim_get_current_line()
  local col = vim.api.nvim_win_get_cursor(0)[2] + 1
  for _, ref in ipairs(parse_refs(line)) do
    if col >= ref.s and col <= ref.e then
      local chosen = #ref.segments
      for k = 1, #ref.segments - 1 do
        if col <= ref.starts[k] + #ref.segments[k] + 1 then
          chosen = k
          break
        end
      end
      local trimmed = {}
      for k = 1, chosen do
        trimmed[k] = ref.segments[k]
      end
      return trimmed, chosen == #ref.segments, ref.candidates
    end
  end
end

local function resolve_ref(segments, is_last, candidates)
  if not is_last then
    return search_buffers(segments, false)
  end
  local probe = vim.deepcopy(segments)
  for _, cand in ipairs(candidates) do
    probe[#probe] = cand
    local buf, lnum = search_buffers(probe, false)
    if buf then
      return buf, lnum
    end
  end
  probe[#probe] = candidates[#candidates]
  return search_buffers(probe, true)
end

vim.api.nvim_set_hl(0, "UnresolvedRef", { undercurl = true, sp = "#a23a2b", fg = "#a23a2b" })
local ref_ns = vim.api.nvim_create_namespace "unresolved_refs"

local function check_refs(first, last)
  local buf = vim.api.nvim_get_current_buf()
  vim.api.nvim_buf_clear_namespace(buf, ref_ns, 0, -1)
  local fenced = false
  local total, found = 0, 0
  for lnum, line in ipairs(vim.api.nvim_buf_get_lines(buf, 0, last, false)) do
    if line:match "^%s*```" or line:match "^%s*~~~" then
      fenced = not fenced
    elseif not fenced and lnum >= first then
      for _, ref in ipairs(parse_refs(line)) do
        total = total + 1
        if resolve_ref(ref.segments, true, ref.candidates) then
          found = found + 1
        else
          vim.api.nvim_buf_set_extmark(buf, ref_ns, lnum - 1, ref.s - 1, {
            end_col = ref.e,
            hl_group = "UnresolvedRef",
            priority = 400,
          })
        end
      end
    end
  end
  if found < total then
    vim.api.nvim_create_autocmd("TextChanged", {
      buffer = buf,
      once = true,
      callback = function()
        vim.api.nvim_buf_clear_namespace(buf, ref_ns, 0, -1)
      end,
    })
  end
  print(("[%d/%d]"):format(found, total))
end

vim.keymap.set("n", "<Leader>wcr", function()
  check_refs(1, vim.api.nvim_buf_line_count(0))
end, { desc = "Count resolvable list references in file" })

vim.keymap.set("x", "<Leader>wcr", function()
  local first = vim.fn.line "v"
  local last = vim.fn.line "."
  if first > last then
    first, last = last, first
  end
  vim.cmd "normal! \27"
  check_refs(first, last)
end, { desc = "Count resolvable list references in selection" })

vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function(args)
    vim.keymap.set("n", "gd", function()
      local segments, is_last, candidates = scope_at_cursor()
      if not segments then
        vim.cmd "normal! gd"
        return
      end
      local buf, lnum
      if is_last then
        local probe = vim.deepcopy(segments)
        for _, cand in ipairs(candidates) do
          probe[#probe] = cand
          buf, lnum = search_buffers(probe, false)
          if buf then
            break
          end
        end
        if not buf then
          probe[#probe] = candidates[#candidates]
          buf, lnum = search_buffers(probe, true)
        end
      else
        buf, lnum = search_buffers(segments, false)
      end
      if not buf then
        vim.notify("Scope not found: " .. table.concat(segments, "::"), vim.log.levels.WARN)
        return
      end
      vim.cmd "normal! m'"
      if buf ~= vim.api.nvim_get_current_buf() then
        vim.api.nvim_set_current_buf(buf)
      end
      local line = vim.api.nvim_buf_get_lines(buf, lnum - 1, lnum, false)[1]
      vim.api.nvim_win_set_cursor(0, { lnum, line:find "%S" - 1 })
      vim.cmd "normal! zvzz"
    end, { buffer = args.buf, desc = "Jump to list item for scope" })
  end,
})

-- copy list item as a construct
vim.keymap.set("n", "yc", function()
  local row = vim.api.nvim_win_get_cursor(0)[1]
  local current = list_item_text(row)
  if not current then
    return
  end
  local parts = {}
  local level = vim.fn.indent(row)
  for lnum = row - 1, 1, -1 do
    if level == 0 then
      break
    end
    local text = list_item_text(lnum)
    if text then
      local indent = vim.fn.indent(lnum)
      if indent < level then
        table.insert(parts, 1, (text:gsub("%s+", "_")))
        level = indent
      end
    end
  end
  table.insert(parts, current)
  local result = table.concat(parts, "::")
  vim.fn.setreg('"', result)
  vim.fn.setreg("+", result)
  vim.notify(result)
end, { desc = "Copy list item path" })



local function md_buffers()
  local current = vim.api.nvim_get_current_buf()
  local order = { current }
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if buf ~= current and vim.bo[buf].buflisted and vim.api.nvim_buf_get_name(buf):match "%.md$" then
      if not vim.api.nvim_buf_is_loaded(buf) then
        vim.fn.bufload(buf)
      end
      table.insert(order, buf)
    end
  end
  return order
end

local function ref_hits_target(ref, target_buf, target_lnum, target_raw)
  local n = #ref.segments
  for k = 1, n do
    local possible
    if k < n then
      possible = (target_raw:gsub("%s+", "_")) == ref.segments[k]
    else
      possible = target_raw:sub(1, #ref.segments[n]) == ref.segments[n]
    end
    if possible then
      local trimmed = {}
      for i = 1, k do
        trimmed[i] = ref.segments[i]
      end
      local buf, lnum
      if k < n then
        buf, lnum = search_buffers(trimmed, false)
      else
        buf, lnum = resolve_ref(trimmed, true, ref.candidates)
      end
      if buf == target_buf and lnum == target_lnum then
        return true
      end
    end
  end
  return false
end

local function find_references()
  local row = vim.api.nvim_win_get_cursor(0)[1]
  local text = list_item_text(row)
  if not text then
    return nil
  end
  text = (text:gsub("^~~(.-)~~$", "%1"))
  local target_buf = vim.api.nvim_get_current_buf()
  local items = {}
  for _, buf in ipairs(md_buffers()) do
    local fenced = false
    for lnum, line in ipairs(vim.api.nvim_buf_get_lines(buf, 0, -1, false)) do
      if line:match "^%s*```" or line:match "^%s*~~~" then
        fenced = not fenced
      elseif not fenced then
        for _, ref in ipairs(parse_refs(line)) do
          if ref_hits_target(ref, target_buf, row, text) then
            table.insert(items, { bufnr = buf, lnum = lnum, col = ref.s, text = vim.trim(line) })
            break
          end
        end
      end
    end
  end
  return items, text
end

-- note to self: this only gets references to the children of the list item hovered, not
-- references the item itself. this behaviour makes sense, as standing at the root node
-- of a tree which is usually 1 word, should get references to all intermediates and leaves
-- rather than references to that single word, which could be unrelated to the list itself
vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function(args)
    vim.keymap.set("n", "grr", function()
      local items, text = find_references()
      if not items then
        vim.lsp.buf.references()
        return
      end
      if #items == 0 then
        vim.notify("No references to: " .. text, vim.log.levels.WARN)
        return
      end
      vim.fn.setqflist({}, " ", { title = "References: " .. text, items = items })
      vim.cmd "copen"
    end, { buffer = args.buf, desc = "Display references to list item" })
  end,
})

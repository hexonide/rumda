-- wrapping text
local function is_title(line)
  local body = line:match "^%s*(.-)%s*$"
  for _, mark in ipairs { "***", "___", "**", "__", "*", "_" } do
    local inner = body:match("^" .. vim.pesc(mark) .. "([^%*_]+)" .. vim.pesc(mark) .. "$")
    if inner and inner:match "%S" then
      return true
    end
  end
  return false
end

local title_ns = vim.api.nvim_create_namespace "centered_titles"

local function in_indented_code(root, row)
  local node = root:named_descendant_for_range(row, 4, row, 4)
  while node do
    if node:type() == "indented_code_block" then
      return true
    end
    node = node:parent()
  end
  return false
end

local function define_title_hl()
  local normal = vim.api.nvim_get_hl(0, { name = "Normal", link = false })
  local base = { fg = normal.fg, bg = normal.bg }
  vim.api.nvim_set_hl(0, "CenteredTitleBold", vim.tbl_extend("force", base, { bold = true }))
  vim.api.nvim_set_hl(0, "CenteredTitleItalic", vim.tbl_extend("force", base, { italic = true }))
  vim.api.nvim_set_hl(0, "CenteredTitleBoldItalic", vim.tbl_extend("force", base, { bold = true, italic = true }))
end

define_title_hl()
vim.api.nvim_create_autocmd("ColorScheme", { callback = define_title_hl })

local function title_group(line)
  local body = line:match "^%s*(.-)%s*$"
  if body:match "^%*%*%*" or body:match "^___" then
    return "CenteredTitleBoldItalic"
  elseif body:match "^%*%*" or body:match "^__" then
    return "CenteredTitleBold"
  end
  return "CenteredTitleItalic"
end

local function conceal_markers(buf, row, line)
  local body = line:match "^%s*(.-)%s*$"
  local lead = #line:match "^%s*"
  for _, mark in ipairs { "***", "___", "**", "__", "*", "_" } do
    local n = #mark
    if #body > 2 * n and body:sub(1, n) == mark and body:sub(-n) == mark then
      vim.api.nvim_buf_set_extmark(buf, title_ns, row, lead, { end_col = lead + n, conceal = "" })
      vim.api.nvim_buf_set_extmark(buf, title_ns, row, lead + #body - n, { end_col = lead + #body, conceal = "" })
      return
    end
  end
end

local function mark_titles(buf)
  vim.api.nvim_buf_clear_namespace(buf, title_ns, 0, -1)
  local ok, parser = pcall(vim.treesitter.get_parser, buf, "markdown")
  if not ok or not parser then
    return
  end
  local root = parser:parse()[1]:root()
  for i, line in ipairs(vim.api.nvim_buf_get_lines(buf, 0, -1, false)) do
    if line:match "^%s%s%s%s" and is_title(line) and in_indented_code(root, i - 1) then
      vim.api.nvim_buf_set_extmark(buf, title_ns, i - 1, 0, {
        end_col = #line,
        hl_group = title_group(line),
        priority = 300,
      })
      conceal_markers(buf, i - 1, line)
    end
  end
end

vim.api.nvim_create_autocmd({ "FileType", "BufEnter", "TextChanged" }, {
  callback = function(args)
    if vim.bo[args.buf].filetype == "markdown" then
      mark_titles(args.buf)
    end
  end,
})

local function is_prose(line)
  if line:match "^%s*$" then
    return false
  end
  if line:match "^%s*|" or line:match "^%s*#+%s" or line:match "^%s*>" or line:match "^%s*<" then
    return false
  end
  if line:match "^%s*([-*_])%s*%1%s*%1[%s%-%*_]*$" then
    return false
  end
  local body = line:match "^%s*[%*%-%+]%s+(.-)%s*$" or line:match "^%s*%d+[.)]%s+(.-)%s*$" or line
  return not is_title(body)
end

local function center_titles(first, last, width)
  local fenced = false
  for lnum, line in ipairs(vim.api.nvim_buf_get_lines(0, 0, last, false)) do
    if line:match "^%s*```" or line:match "^%s*~~~" then
      fenced = not fenced
    elseif not fenced and lnum >= first then
      local is_target = is_title(line) and not line:match "^%s*[%*%-%+]%s" and not line:match "^%s*%d+[.)]%s"
      -- is_target = is_target or line:match "^%s*#+%s"
      if is_target then
        local text = line:match "^%s*(.-)%s*$"
        local pad = math.max(0, math.floor((width - vim.fn.strdisplaywidth(text)) / 2))
        vim.api.nvim_buf_set_lines(0, lnum - 1, lnum, false, { string.rep(" ", pad) .. text })
      end
    end
  end
end

local tw_range = { 70, 90 }

local function reflow_ranges(buf, ranges, offset, width)
  local total, count = 0, 0
  vim.api.nvim_buf_call(buf, function()
    local saved = {
      tw = vim.bo.textwidth,
      fo = vim.bo.formatoptions,
      fe = vim.bo.formatexpr,
      flp = vim.bo.formatlistpat,
    }
    vim.bo.textwidth = width
    vim.bo.formatexpr = ""
    vim.bo.formatoptions = saved.fo:gsub("n", "") .. "n"
    vim.bo.formatlistpat = [[^\s*\d\+[\]:.)}\t ]\s*\|^\s*[-*+]\s\+]]
    for i = #ranges, 1, -1 do
      local s, e = ranges[i][1] - offset, ranges[i][2] - offset
      local before = vim.api.nvim_buf_line_count(0)
      vim.cmd(("normal! %dGgq%dG"):format(s, e))
      local new_end = e + vim.api.nvim_buf_line_count(0) - before
      local res = vim.api.nvim_buf_get_lines(0, s - 1, new_end, false)
      for j = 1, #res - 1 do
        local nxt = res[j + 1]
        if not nxt:match "^%s*[%*%-%+]%s" and not nxt:match "^%s*%d+[.)]%s" then
          local gap = width - vim.fn.strdisplaywidth(res[j])
          total = total + gap * gap
          count = count + 1
        end
      end
    end
    vim.bo.textwidth = saved.tw
    vim.bo.formatoptions = saved.fo
    vim.bo.formatexpr = saved.fe
    vim.bo.formatlistpat = saved.flp
  end)
  return count > 0 and total / count or 0
end

local function wrap_selection(count, center)
  local first = vim.fn.line "v"
  local last = vim.fn.line "."
  if first > last then
    first, last = last, first
  end
  vim.cmd "normal! \27"
  local lines = vim.api.nvim_buf_get_lines(0, 0, last, false)
  local fenced = false
  local ranges = {}
  local open
  for lnum, line in ipairs(lines) do
    local is_fence = line:match "^%s*```" or line:match "^%s*~~~"
    local ok = false
    if is_fence then
      fenced = not fenced
    elseif not fenced and lnum >= first then
      ok = is_prose(line)
    end
    if ok then
      open = open or lnum
    elseif open then
      table.insert(ranges, { open, lnum - 1 })
      open = nil
    end
  end
  if open then
    table.insert(ranges, { open, last })
  end

  local width = count
  if #ranges > 0 then
    if count == 0 then
      local snapshot = vim.api.nvim_buf_get_lines(0, first - 1, last, false)
      local scratch = vim.api.nvim_create_buf(false, true)
      for _, opt in ipairs { "tabstop", "shiftwidth", "expandtab", "comments" } do
        vim.bo[scratch][opt] = vim.bo[opt]
      end
      local best
      for w = tw_range[2], tw_range[1], -1 do
        vim.api.nvim_buf_set_lines(scratch, 0, -1, false, snapshot)
        local score = reflow_ranges(scratch, ranges, first - 1, w)
        if not best or score < best then
          best = score
          width = w
        end
      end
      vim.api.nvim_buf_delete(scratch, { force = true })
      vim.notify("Wrapped at " .. width)
    end
    local before = vim.api.nvim_buf_line_count(0)
    reflow_ranges(0, ranges, 0, width)
    last = last + vim.api.nvim_buf_line_count(0) - before
  elseif width == 0 then
    width = math.floor((tw_range[1] + tw_range[2]) / 2)
  end

  if center then
    center_titles(first, last, width)
  end
  vim.api.nvim_win_set_cursor(0, { first, 0 })
end

vim.keymap.set("x", "tw", function()
  wrap_selection(vim.v.count, false)
end, { desc = "Rewrap/align text prose in selected lines" })

vim.keymap.set("x", "taw", function()
  wrap_selection(vim.v.count, true)
end, { desc = "Rewrap/align text prose & then center titles" })

-- inline comment padding control
vim.keymap.set("n", "gy", function()
  local target = vim.v.count > 0 and vim.v.count or 65
  local line = vim.api.nvim_get_current_line()
  local pad = target - 1 - vim.fn.strdisplaywidth(line)
  if pad > 0 then
    vim.api.nvim_set_current_line(line .. string.rep(" ", pad))
  end
  vim.cmd "startinsert!"
end, { desc = "Pad line to column and insert" })

local function comment_start(row, line)
  local trimmed = line:gsub("%s+$", "")
  if trimmed == "" then
    return nil
  end
  local ok, node = pcall(vim.treesitter.get_node, { bufnr = 0, pos = { row, #trimmed - 1 } })
  if ok and node then
    while node:parent() and node:parent():type():match "comment" do
      node = node:parent()
    end
    if node:type():match "comment" then
      local srow, scol = node:range()
      if srow == row then
        return scol
      end
    end
    return nil
  end
  local leader = vim.bo.commentstring:match "^(.-)%s*%%s"
  if leader and leader ~= "" then
    local idx = line:find(leader, 1, true)
    return idx and idx - 1
  end
end

vim.keymap.set("x", "gy", function()
  local target = vim.v.count > 0 and vim.v.count or 65
  local first = vim.fn.line "v"
  local last = vim.fn.line "."
  if first > last then
    first, last = last, first
  end
  for lnum = first, last do
    local line = vim.fn.getline(lnum)
    local start = comment_start(lnum - 1, line)
    if start then
      local code = line:sub(1, start):gsub("%s+$", "")
      local pad = target - 1 - vim.fn.strdisplaywidth(code)
      if code == "" or pad >= 1 then
        vim.fn.setline(lnum, code .. string.rep(" ", math.max(pad, 0)) .. line:sub(start + 1))
      end
    end
  end
  vim.cmd "normal! \27"
end, { desc = "Align inline comments to column" })

-- select inline comment
vim.keymap.set("x", "gs", function()
  local first = vim.fn.line "v"
  local last = vim.fn.line "."
  if first > last then
    first, last = last, first
  end
  vim.cmd "normal! \27"
  local spans = {}
  local top, bottom
  for lnum = first, last do
    local line = vim.fn.getline(lnum)
    local start = comment_start(lnum - 1, line)
    if start then
      local code = line:sub(1, start):gsub("%s+$", "")
      spans[lnum] = { code = code, comment = line:sub(start + 1) }
      top = top or lnum
      bottom = lnum
    end
  end
  if not top then
    return
  end
  local width = 0
  for lnum = top, bottom do
    local text = spans[lnum] and spans[lnum].code or vim.fn.getline(lnum)
    width = math.max(width, vim.fn.strdisplaywidth(text))
  end
  for lnum, span in pairs(spans) do
    local pad = width + 1 - vim.fn.strdisplaywidth(span.code)
    vim.fn.setline(lnum, span.code .. string.rep(" ", pad) .. span.comment)
  end
  vim.api.nvim_win_set_cursor(0, { top, 0 })
  vim.cmd("normal! " .. (width + 2) .. "|")
  vim.cmd "normal! \22"
  vim.cmd("normal! " .. (bottom - top) .. "j")
  vim.cmd "normal! $"
end, { desc = "Select inline comments of selected lines" })


-- Keybinds:

vim.api.nvim_set_keymap("n", "<M-h>", ":vsplit | terminal<CR> | resize 50%<CR>", { noremap = true, silent = true })

-- macro for the double loop
vim.cmd [[
    let @a = 'i  for (int i = 0; i < 10; i++) {for (int k = 0; k < 10; k++) {}}'
]]
vim.api.nvim_set_keymap("n", "<leader>l", "@a", { noremap = true, silent = true })
-- Markdown formatting keymaps (accessed via <Leader>w)
vim.keymap.set("v", "<Leader>wb", 'c**<C-r>"**<Esc>', { desc = "Bold selection" })
vim.keymap.set("v", "<Leader>wi", 'c*<C-r>"*<Esc>', { desc = "Italic selection" })
vim.keymap.set("v", "<Leader>wu", 'c_<C-r>"_<Esc>', { desc = "Underline/emphasis selection" })
vim.keymap.set("v", "<Leader>wl", 'c[<C-r>"]()<Esc>i', { desc = "Create link (add URL)" })
vim.keymap.set("v", "<Leader>ws", 'c~<C-r>"~<Esc>', { desc = "Strikethrough" })

-- Text wrappers (accessed via <Leader>w)
vim.keymap.set("v", "<Leader>w[", 'c_[<C-r>"]_<Esc>', { desc = "Wrap in _[text]_" })
vim.keymap.set("v", "<Leader>w(", 'c(<C-r>")<Esc>', { desc = "Wrap in (text)" })
vim.keymap.set("v", "<Leader>w{", 'c{<C-r>"}<Esc>', { desc = "Wrap in {text}" })
vim.keymap.set("v", "<Leader>w]", 'c[<C-r>"]<Esc>', { desc = "Wrap in [text]" })
vim.keymap.set("v", '<Leader>w"', 'c"<C-r>""<Esc>', { desc = 'Wrap in "text"' })
vim.keymap.set("v", "<Leader>w'", "c'<C-r>\"'<Esc>", { desc = "Wrap in 'text'" })
vim.keymap.set("v", "<Leader>w<", 'c<<C-r>"><Esc>', { desc = "Wrap in <text>" })
vim.keymap.set("v", "<Leader>w`", 'c`<C-r>"`<Esc>', { desc = "Wrap in `text`" })

-- Code block
vim.keymap.set("n", "<Leader>wcb", "i```<CR>```<Esc>O", { desc = "Code block" })

-- Subscript and superscript
vim.keymap.set("v", "<Leader>wS", 'c<sup><C-r>"</sup><Esc>', { desc = "Superscript (wrap in <sup>)" })
vim.keymap.set("v", "<Leader>wd", 'c<sub><C-r>"</sub><Esc>', { desc = "Subscript (wrap in <sub>)" })

-- Collapsible details block (selection becomes hidden)
vim.keymap.set(
  "v",
  "<Leader>wD",
  'c<details><CR><summary>collapsible</summary><CR><C-r>"<CR></details><Esc>',
  { desc = "Wrap in <details> (selection is collapsed)" }
)

-- CURSOR AND SCROLLING STUFF
vim.keymap.set("n", "<leader>tn", ":set relativenumber!<CR>", { desc = "Toggle relative numbers on lines" })
vim.opt.number = true -- Show absolute line number on current line
vim.opt.relativenumber = false -- show relative nums for other lines
vim.opt.scrolloff = 0

-- git hunks
vim.keymap.set("n", "]h", function()
  require("gitsigns").next_hunk()
end, { desc = "Next Git hunk" })
vim.keymap.set("n", "[h", function()
  require("gitsigns").prev_hunk()
end, { desc = "Previous Git hunk" })

-- insert underscore on <count> char
local function insert_underscore(direction)
  local count = vim.v.count1
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  local len = #vim.api.nvim_get_current_line()
  local at, cursor

  if direction > 0 then
    at = math.min(col + count, len)
    cursor = math.min(at + 1, len)
  else
    at = math.max(col - count + 1, 0)
    cursor = math.max(at - 1, 0)
  end

  vim.api.nvim_buf_set_text(0, row - 1, at, row - 1, at, { "_" })
  vim.api.nvim_win_set_cursor(0, { row, cursor })
end

vim.keymap.set("n", "]u", function()
  insert_underscore(1)
end, { desc = "Insert underscore N chars right" })

vim.keymap.set("n", "[u", function()
  insert_underscore(-1)
end, { desc = "Insert underscore N chars left" })

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

-- Error toggling
local diagnostic_modes = {
  { name = "errors only", min = vim.diagnostic.severity.ERROR },
  { name = "errors and warnings", min = vim.diagnostic.severity.WARN },
  { name = "everything", min = vim.diagnostic.severity.HINT },
  { name = "hidden", min = nil },
}

local diagnostic_index = 1

local function apply_diagnostic_mode()
  local mode = diagnostic_modes[diagnostic_index]
  if mode.min == nil then
    vim.diagnostic.config {
      virtual_text = false,
      signs = false,
      underline = false,
    }
    return
  end
  local filter = { severity = { min = mode.min } }
  vim.diagnostic.config {
    severity_sort = true,
    signs = filter,
    virtual_text = filter,
    underline = filter,
    float = filter,
  }
end

vim.schedule(apply_diagnostic_mode)
vim.api.nvim_create_autocmd("LspAttach", { callback = apply_diagnostic_mode })

vim.keymap.set("n", "<Leader>td", function()
  diagnostic_index = diagnostic_index % #diagnostic_modes + 1
  apply_diagnostic_mode()
  vim.notify("Diagnostics: " .. diagnostic_modes[diagnostic_index].name)
end, { desc = "Cycle diagnostic visibility" })

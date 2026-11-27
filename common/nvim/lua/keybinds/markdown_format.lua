-- Markdown formatting keymaps (accessed via <Leader>w)
vim.keymap.set("v", "<Leader>wb", 'c**<C-r>"**<Esc>', { desc = "Bold selection" })
vim.keymap.set("v", "<Leader>wi", 'c*<C-r>"*<Esc>', { desc = "Italic selection" })
vim.keymap.set("v", "<Leader>wu", 'c_<C-r>"_<Esc>', { desc = "Underline/emphasis selection" })
vim.keymap.set("v", "<Leader>wl", '"zc[<C-r>z]()<Esc>i', { desc = "Create link (add URL)" })
vim.keymap.set("v", "<Leader>ws", 'c~~<C-r>"~~<Esc>', { desc = "Strikethrough" })

-- Text wrappers (accessed via <Leader>w)
vim.keymap.set("v", "<Leader>w[", 'c_[<C-r>"]_<Esc>', { desc = "Wrap in _[text]_" })
vim.keymap.set("v", "<Leader>w(", 'c(<C-r>")<Esc>', { desc = "Wrap in (text)" })
vim.keymap.set("v", "<Leader>w{", 'c{<C-r>"}<Esc>', { desc = "Wrap in {text}" })
vim.keymap.set("v", "<Leader>w]", 'c[<C-r>"]<Esc>', { desc = "Wrap in [text]" })
vim.keymap.set("v", '<Leader>w"', 'c"<C-r>""<Esc>', { desc = 'Wrap in "text"' })
vim.keymap.set("v", "<Leader>w'", "c'<C-r>\"'<Esc>", { desc = "Wrap in 'text'" })
vim.keymap.set("v", "<Leader>w<", 'c<<C-r>"><Esc>', { desc = "Wrap in <text>" })
vim.keymap.set("v", "<Leader>w`", 'c`<C-r>"`<Esc>', { desc = "Wrap in `text`" })

-- unwrap strikethrough
vim.keymap.set("v", "<Leader>wS", function()
  local first = vim.fn.line "v"
  local last = vim.fn.line "."
  if first > last then
    first, last = last, first
  end
  vim.cmd "normal! \27"
  for lnum = first, last do
    local line = vim.fn.getline(lnum)
    local stripped = line:gsub("~~(.-)~~", "%1")
    if stripped ~= line then
      vim.fn.setline(lnum, stripped)
    end
  end
end, { desc = "Remove strikethrough from selected lines" })

-- count strikethrough
local function strike_count(first, last)
  local struck, total = 0, 0
  for _, line in ipairs(vim.api.nvim_buf_get_lines(0, first - 1, last, false)) do
    if line:match "%S" then
      total = total + 1
      if line:find "~~.-~~" then
        struck = struck + 1
      end
    end
  end
  print(("[%d/%d]"):format(struck, total))
end

vim.keymap.set("v", "<Leader>wcs", function()
  local first = vim.fn.line "v"
  local last = vim.fn.line "."
  if first > last then
    first, last = last, first
  end
  vim.cmd "normal! \27"
  strike_count(first, last)
end, { desc = "Count strikethrough lines in selection" })

-- Code block
vim.keymap.set("n", "<Leader>wcb", "i```<CR>```<Esc>O", { desc = "Code block" })

-- Subscript and superscript
vim.keymap.set("v", "<Leader>wd", 'c<sub><C-r>"</sub><Esc>', { desc = "Subscript (wrap in <sub>)" })
vim.keymap.set("v", "<Leader>wD", 'c<sup><C-r>"</sup><Esc>', { desc = "Superscript (wrap in <sup>)" })

-- Collapsible details block (selection becomes hidden)
vim.keymap.set(
  "v",
  "<Leader>wx",
  'c<details><CR><summary>collapsible</summary><CR><C-r>"<CR></details><Esc>',
  { desc = "Wrap in <details> (selection is collapsed)" }
)

-- Keybinds:

vim.api.nvim_set_keymap("n", "<M-h>", ":vsplit | terminal<CR> | resize 50%<CR>", { noremap = true, silent = true })
-- paste w/o replace
vim.keymap.set("x", "<C-p>", "P", { desc = "Paste over selection without overwriting register" })

-- macro for the double loop
vim.cmd [[
    let @a = 'i  for (int i = 0; i < 10; i++) {for (int k = 0; k < 10; k++) {}}'
]]
vim.api.nvim_set_keymap("n", "<leader>l", "@a", { noremap = true, silent = true })

-- CURSOR AND SCROLLING STUFF
vim.keymap.set("n", "<leader>tn", ":set relativenumber!<CR>", { desc = "Toggle relative numbers on lines" })

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

-- whitespace del
vim.keymap.set("n", "<Leader>tw", function()
  local id = vim.fn.matchadd("Search", [[\s\+$]], 100)
  vim.cmd "redraw"
  local choice = vim.fn.confirm("Delete highlighted trailing whitespace?", "&Yes\n&No", 2)
  vim.fn.matchdelete(id)
  if choice == 1 then
    local view = vim.fn.winsaveview()
    vim.cmd [[keeppatterns %s/\s\+$//e]]
    vim.fn.winrestview(view)
  end
end, { desc = "Preview and trim trailing whitespace" })

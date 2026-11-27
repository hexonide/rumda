require "nvchad.options"

-- add yours here!

-- local o = vim.o
-- o.cursorlineopt ='both' -- to enable cursorline!
-- vim.opt.guicursor = "n-v-c:block-Cursor,i-ci-ve:ver10-iCursor,r-cr-o:ver20-rCursor,a:blinkwait700-blinkoff400-blinkon250"
-- vim.opt.arabicshape = false
vim.opt.timeoutlen = 1000
vim.opt.number = true -- Show absolute line number on current line
vim.opt.relativenumber = false -- show relative nums for other lines
vim.opt.scrolloff = 4

require "highlights.scope_root"

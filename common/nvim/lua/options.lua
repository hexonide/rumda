require "nvchad.options"

-- add yours here!

-- local o = vim.o
-- o.cursorlineopt ='both' -- to enable cursorline!
-- vim.opt.guicursor = "n-v-c:block-Cursor,i-ci-ve:ver10-iCursor,r-cr-o:ver20-rCursor,a:blinkwait700-blinkoff400-blinkon250"
-- vim.opt.arabicshape = false

vim.opt.number = true -- Show absolute line number on current line
vim.opt.relativenumber = false -- show relative nums for other lines
vim.opt.scrolloff = 0



-- highlights stuff like `root::median::item` differently in markdown
vim.api.nvim_set_hl(0, "ScopeRoot", { link = "@markup.raw" })
vim.api.nvim_create_autocmd("ColorScheme", {
  callback = function()
    vim.api.nvim_set_hl(0, "ScopeRoot", { link = "@markup.raw" })
  end,
})

local ns = vim.api.nvim_create_namespace "scope_root"

local function mark_scopes(buf)
  vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
  local ok, parser = pcall(vim.treesitter.get_parser, buf, "markdown")
  if not ok or not parser then
    return
  end
  local root = parser:parse()[1]:root()
  local function in_code(row, col)
    local node = root:named_descendant_for_range(row, col, row, col)
    while node do
      local kind = node:type()
      if kind == "fenced_code_block" or kind == "indented_code_block" then
        return true
      end
      node = node:parent()
    end
    return false
  end
  for i, line in ipairs(vim.api.nvim_buf_get_lines(buf, 0, -1, false)) do
    local init = 1
    while true do
      local s, e = line:find("[%w_%-]+::[%w_%-:]*[%w_%-]", init)
      if not s then
        break
      end
      if not in_code(i - 1, s - 1) then
        local root_end = line:find("::", s, true) - 1
        vim.api.nvim_buf_set_extmark(buf, ns, i - 1, s - 1, {
          end_col = root_end,
          hl_group = "ScopeRoot",
          priority = 300,
        })
      end
      init = e + 1
    end
  end
end

vim.api.nvim_create_autocmd({ "FileType", "BufEnter", "TextChanged", "TextChangedI" }, {
  callback = function(args)
    if vim.bo[args.buf].filetype == "markdown" then
      mark_scopes(args.buf)
    else
      vim.api.nvim_buf_clear_namespace(args.buf, ns, 0, -1)
    end
  end,
})

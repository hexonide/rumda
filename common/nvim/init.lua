vim.g.base46_cache = vim.fn.stdpath "data" .. "/base46/"
vim.g.mapleader = " "

-- bootstrap lazy and all plugins
local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  local repo = "https://github.com/folke/lazy.nvim.git"
  vim.fn.system { "git", "clone", "--filter=blob:none", repo, "--branch=stable", lazypath }
end

vim.opt.rtp:prepend(lazypath)

local lazy_config = require "configs.lazy"

-- load plugins
require("lazy").setup({
  {
    "NvChad/NvChad",
    lazy = false,
    branch = "v2.5",
    import = "nvchad.plugins",
  },
  {
    "IogaMaster/neocord",
    event = "VeryLazy",
    opts = function()
      local cache = {}

      local function project()
        local dir = vim.fn.expand "%:p:h"
        if dir == "" then
          dir = vim.fn.getcwd()
        end
        if cache[dir] == nil then
          local out = vim.fn.systemlist { "git", "-C", dir, "rev-parse", "--show-toplevel" }
          if vim.v.shell_error == 0 and out[1] then
            cache[dir] = vim.fn.fnamemodify(out[1], ":t")
          else
            cache[dir] = vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
          end
        end
        return "Working on " .. cache[dir]
      end

      local function file_info()
        return "Editing " .. vim.fn.expand "%:t" .. " in " .. vim.fn.expand "%:p:h:t"
      end

      return {
        logo = "auto",
        logo_tooltip = "Neovim",
        main_image = "language",
        show_time = true,
        global_timer = true,
        debounce_timeout = 10,
        blacklist = { "NvimTree", "dashboard" },
        editing_text = file_info,
        reading_text = file_info,
        terminal_text = file_info,
        line_number_text = "Line %s out of %s",
        workspace_text = project,
      }
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = { "lua", "cpp", "c", "python", "markdown", "markdown_inline" },
      highlight = { enable = true },
    },
  },
  { import = "plugins" },
}, lazy_config)

-- Keymaps
vim.api.nvim_set_keymap("n", "<M-h>", ":vsplit | terminal<CR> | resize 50%<CR>", { noremap = true, silent = true })

-- Define the macro for the double loop
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

vim.keymap.set("n", "]h", function() require("gitsigns").next_hunk() end, { desc = "Next Git hunk" })
vim.keymap.set("n", "[h", function() require("gitsigns").prev_hunk() end, { desc = "Previous Git hunk" })


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

vim.g.mkdp_browser = "firefox"

-- load theme
dofile(vim.g.base46_cache .. "defaults")
dofile(vim.g.base46_cache .. "statusline")

require "options"
require "nvchad.autocmds"

vim.schedule(function()
  require "mappings"
end)

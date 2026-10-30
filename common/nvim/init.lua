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

vim.g.mkdp_browser = "firefox"

-- load theme
dofile(vim.g.base46_cache .. "defaults")
dofile(vim.g.base46_cache .. "statusline")

require "options"
require "nvchad.autocmds"

vim.schedule(function()
  require "mappings"
  require "keybinds"
end)

local reload_pending = false

local function reload_theme()
  for name in pairs(package.loaded) do
    if name:match "^themes%." or name == "chadrc" or name == "nvconfig" then
      package.loaded[name] = nil
    end
  end
  require("base46").load_all_highlights()
  vim.cmd "redraw!"
end

local function queue_reload()
  if reload_pending then
    return
  end
  reload_pending = true
  vim.defer_fn(function()
    reload_pending = false
    reload_theme()
  end, 150)
end

local function watch(dir, accept)
  local handle = vim.uv.new_fs_event()
  if not handle then
    return
  end
  handle:start(dir, {}, function(err, filename)
    if err or not filename or not accept(filename) then
      return
    end
    vim.schedule(queue_reload)
  end)
end

local config_dir = vim.fn.stdpath "config" .. "/lua"
watch(config_dir .. "/themes", function(name)
  return name:match "%.lua$" ~= nil
end)
watch(config_dir, function(name)
  return name == "chadrc.lua"
end)

local comment_state = {}

local function apply_comment()
  for _, group in ipairs { "Comment", "@comment" } do
    local hl = vim.api.nvim_get_hl(0, { name = group, link = false })
    if comment_state.fg then
      hl.fg = comment_state.fg
    end
    if comment_state.italic ~= nil then
      hl.italic = comment_state.italic
    end
    vim.api.nvim_set_hl(0, group, hl)
  end
end

vim.api.nvim_create_user_command("CommentStyle", function(opts)
  local arg, value = opts.fargs[1], opts.fargs[2]
  if arg == "reset" then
    comment_state = {}
    require("base46").load_all_highlights()
    return
  elseif arg == "italic" then
    comment_state.italic = true
  elseif arg == "upright" then
    comment_state.italic = false
  elseif arg == "color" and value and value:match "^#%x%x%x%x%x%x$" then
    comment_state.fg = tonumber(value:sub(2), 16)
  else
    vim.notify("CommentStyle: color #rrggbb | italic | upright | reset", vim.log.levels.WARN)
    return
  end
  apply_comment()
end, {
  nargs = "+",
  complete = function()
    return { "color", "italic", "upright", "reset" }
  end,
})

vim.api.nvim_create_autocmd("ColorScheme", {
  callback = function()
    if next(comment_state) then
      apply_comment()
    end
  end,
})

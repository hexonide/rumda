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


-- keybinds list (momentary)
local registry = {}
local roots = { vim.fn.stdpath "config", vim.uv.fs_realpath(vim.fn.stdpath "config") }
local original_set = vim.keymap.set

vim.keymap.set = function(mode, lhs, rhs, opts)
  local src = debug.getinfo(2, "S").source
  if src:sub(1, 1) == "@" then
    for _, root in ipairs(roots) do
      if root and src:find(root, 1, true) then
        table.insert(registry, {
          modes = type(mode) == "table" and table.concat(mode, ",") or mode,
          lhs = lhs,
          desc = type(opts) == "table" and opts.desc or "",
          file = vim.fn.fnamemodify(src:sub(2), ":t"),
        })
        break
      end
    end
  end
  return original_set(mode, lhs, rhs, opts)
end

vim.api.nvim_create_user_command("Keys", function()
  local pickers = require "telescope.pickers"
  local finders = require "telescope.finders"
  local conf = require("telescope.config").values
  local actions = require "telescope.actions"
  table.sort(registry, function(a, b)
    if a.file ~= b.file then
      return a.file < b.file
    end
    return a.lhs < b.lhs
  end)
  pickers
    .new({}, {
      prompt_title = "Custom keybinds",
      finder = finders.new_table {
        results = registry,
        entry_maker = function(k)
          local lhs = k.lhs:gsub("<[Ll]eader>", "<Space>")
          local text = ("%-5s %-18s %-45s %s"):format(k.modes, lhs, k.desc, k.file)
          return { value = k, display = text, ordinal = text }
        end,
      },
      sorter = conf.generic_sorter {},
      attach_mappings = function(prompt_bufnr)
        actions.select_default:replace(actions.close)
        return true
      end,
    })
    :find()
end, {})

vim.keymap.set("n", "<Leader>kb", "<cmd>Keys<cr>", { desc = "Show custom keybinds" })


-- load plugins
require("lazy").setup({
  {
    "NvChad/NvChad",
    lazy = false,
    branch = "v2.5",
    import = "nvchad.plugins",
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

  local utils = require "nvchad.utils"
  local original_list = utils.list_themes
  local hidden = {}

  utils.list_themes = function()
    local custom, is_custom = {}, {}
    local dir = vim.fn.stdpath "config" .. "/lua/themes"
    for _, file in ipairs(vim.fn.readdir(dir)) do
      local name = file:match "(.+)%..+"
      if name then
        table.insert(custom, name)
        is_custom[name] = true
      end
    end
    local skip = {}
    for _, name in ipairs(hidden) do
      skip[name] = true
    end
    for _, name in ipairs(original_list()) do
      if not is_custom[name] and not skip[name] then
        table.insert(custom, name)
      end
    end
    return custom
  end
end)

local reload_pending = false

local function reload_theme()
  for name in pairs(package.loaded) do
    if name:match "^themes%." or name == "chadrc" or name == "nvconfig" then
      package.loaded[name] = nil
    end
  end
  require("base46").load_all_highlights()
  vim.api.nvim_exec_autocmds("ColorScheme", {})
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

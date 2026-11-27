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

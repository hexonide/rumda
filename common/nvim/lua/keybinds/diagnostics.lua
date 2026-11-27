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

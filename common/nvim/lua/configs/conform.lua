local options = {
  formatters_by_ft = {
    lua = { "stylua" },
    qml = { "qmlformat" },
    -- css = { "prettier" },
    -- html = { "prettier" },
  },

  formatters = {
    qmlformat = {
      command = "/usr/lib64/qt6/bin/qmlformat",
      args = { "--indent-width", "2", "--inplace", "$FILENAME" },
      stdin = false,
      inherit = false,
    },
  },

  -- format_on_save = {
  --   -- These options will be passed to conform.format()
  --   timeout_ms = 500,
  --   lsp_fallback = true,
  -- },
}

return options

local options = {
  formatters_by_ft = {
    lua = { "stylua" },
    -- css = { "prettier" },
    -- html = { "prettier" },
    qml = { "qmlformat" },
  },
  formatters = {
    qmlformat = {
      command = "qmlformat-qt6",
      args = { "--indent-width", "2", "--inplace", "$FILENAME" },
    },
  },

  -- format_on_save = {
  --   -- These options will be passed to conform.format()
  --   timeout_ms = 500,
  --   lsp_fallback = true,
  -- },
}

return options

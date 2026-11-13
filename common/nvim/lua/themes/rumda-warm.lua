local M = {}
M.base_30 = {
  white         = "#1a1410",
  darker_black  = "#dab68f",
  black         = "#f0c997",
  black2        = "#cc9b6e",
  one_bg        = "#d7b184",
  one_bg2       = "#f2bc88",
  one_bg3       = "#c79f7a",
  grey          = "#dba380",
  grey_fg       = "#c98d67",
  light_grey    = "#8f5b3e",
  red           = "#9A4235",
  baby_pink     = "#a87358",
  pink          = "#c47c4f",
  line          = "#d7b184",
  green         = "#5e3b29",
  vibrant_green = "#4e2e1f",
  blue          = "#a1694d",
  yellow        = "#A87358",
  sun           = "#e0b48b",
  purple        = "#c47c4f",
  orange        = "#a87358",
  cyan          = "#a1694d",
  statusline_bg = "#cc9b6e",
  lightbg       = "#e0b48b",
  pmenu_bg      = "#c47c4f",
  folder_bg     = "#a1694d",
}
M.base_16 = {
  base00 = "#f0c997",
  base01 = "#d7b184",
  base02 = "#e0b690",
  base03 = "#9e4234",
  base04 = "#a1694d",
  base05 = "#993d2f",
  base06 = "#2a1d16",
  base07 = "#1a1410",
  base08 = "#9A4235",
  base09 = "#a87358",
  base0A = "#5e3b29",
  base0B = "#447028",
  base0C = "#a1694d",
  base0D = "#426A79",
  base0E = "#a1694d",
  base0F = "#9A4235",
}

local heading_groups = {}
for i = 1, 6 do
  heading_groups["RenderMarkdownH" .. i .. "Bg"] = { bg = M.base_30.black2, fg = M.base_16.base0B, bold = true }
end

heading_groups["RenderMarkdownCode"] = { bg = M.base_30.black2, bold = true }
heading_groups["RenderMarkdownCodeInline"] = { bg = M.base_30.black2, bold = true }

M.type = "light"
M.polish_hl = {
  defaults = heading_groups,
  statusline = {
    St_cwd_icon      = { fg = "#cc9b6e", bg = "#e9bc88" },
    St_cwd_text      = { fg = "#45373c", bg = "#e9bc88" },
    St_cwd_sep       = { fg = "#e9bc88", bg = "#cc9b6e" },
    ---------------------------------------------------
    St_pos_icon      = { fg = "#e9bc88", bg = "#cc9b6e" },
    St_pos_text      = { fg = "#45373c", bg = "#cc9b6e" },
    St_pos_sep       = { fg = "#cc9b6e", bg = "#e9bc88" },
    ---------------------------------------------------
    St_lspError      = { fg = "#a23a2b" },
    St_Lsp           = { fg = "#45373c" },
    St_lspWarning    = { fg = "#e9c193" },
  },
  tbline = {
    TbBufOnClose     = { fg = "#bb2611" },
    TbBufOnModified  = { fg = "#a23a2b" },
    TbBufOffClose    = { fg = "#8d493f" },
    TbBufOffModified = { fg = "#8d493f" },
  },
}

return M

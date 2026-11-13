local M = {}
M.base_30 = {
  white         = "#F0BB90",
  darker_black  = "#1a1410",
  black         = "#1C1612",
  black2        = "#362b22",
  one_bg        = "#362b22",
  one_bg2       = "#3c312a",
  one_bg3       = "#4c4133",
  grey          = "#947957",
  grey_fg       = "#947957",
  light_grey    = "#d19e75",
  red           = "#6e241b",
  baby_pink     = "#d89078",
  pink          = "#cf8860",
  line          = "#362b22",
  green         = "#C47C4F",
  vibrant_green = "#e9a678",
  blue          = "#9f7f65",
  yellow        = "#cf9c75",
  sun           = "#e9c396",
  purple        = "#b88960",
  orange        = "#c89669",
  cyan          = "#9f7f65",
  statusline_bg = "#7a5845",
  lightbg       = "#3D2E21",
  pmenu_bg      = "#8f5b3c",
  folder_bg     = "#5a3a25",
}
M.base_16 = {
  base00 = "#1C1612",
  base01 = "#F5DCC6",
  base02 = "#4c4133",
  base03 = "#d87c6c",
  base04 = "#9f8f82",
  base05 = "#F0BB90",
  base06 = "#c19b76",
  base07 = "#c9c0ae",
  base08 = "#db6657",
  base09 = "#b88960",
  base0A = "#d89371",
  base0B = "#d8864a",
  base0C = "#9f8f82",
  base0D = "#426A79",
  base0E = "#F7B292",
  base0F = "#9A4235",
}

local heading_groups = {}
for i = 1, 6 do
  heading_groups["RenderMarkdownH" .. i .. "Bg"] = { bg = M.base_30.lightbg, fg = M.base_16.base08, bold = true }
end

heading_groups["RenderMarkdownCode"] = { bg = M.base_30.black2, bold = true }
heading_groups["RenderMarkdownCodeInline"] = { bg = M.base_30.black2, bold = true }

M.type = "dark"
M.polish_hl = {
  defaults = heading_groups,
  statusline = {
    St_cwd_icon      = { fg = "#7a5845", bg = "#f0bb90" },
    St_cwd_text      = { fg = "#45373c", bg = "#f0bb90" },
    St_cwd_sep       = { fg = "#f0bb90", bg = "#7a5845" },
    ---------------------------------------------------
    St_pos_icon      = { fg = "#f0bb90", bg = "#7a5845" },
    St_pos_text      = { fg = "#f0bb90", bg = "#7a5845" },
    St_pos_sep       = { fg = "#7a5845", bg = "#f0bb90" },
    ---------------------------------------------------
    St_lspError      = { fg = "#f57f6e" },
    St_Lsp           = { fg = "#f0bb90" },
    St_lspWarning    = { fg = "#e9c193" },
  },
  tbline = {
    TbFill           = { bg = "#7a5845" },
    TbBufOff         = { fg = "#C09B72", bg = "#7a5845" },
    TbBufOn          = { fg = "#f0bb90", bg = "#1c1612" },
    TbBufOnClose     = { fg = "#a23a2b", bg = "#1c1612" },
    TbBufOffClose    = { fg = "#a23a2b", bg = "#7a5845" },
    TbBufOnModified  = { fg = "#a23a2b", bg = "#1c1612" },
    TbBufOffModified = { fg = "#a23a2b", bg = "#7a5845" },
  },
}

return M

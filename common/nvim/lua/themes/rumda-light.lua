local M = {}
M.base_30 = {
  white         = "#45373C",
  darker_black  = "#F2CDAC",
  black         = "#F5DCC6",
  black2        = "#F2CDAC",
  one_bg        = "#F2CDAC",
  one_bg2       = "#f7d5b7",
  one_bg3       = "#e6c0a1",
  grey          = "#cc996c",
  grey_fg       = "#C09B72",
  light_grey    = "#C09B72",
  red           = "#9e5044",
  baby_pink     = "#a87358",
  pink          = "#c47c4f",
  line          = "#c9c0ae",
  green         = "#4e2e1f",
  vibrant_green = "#3e1e0f",
  blue          = "#5a3a25",
  yellow        = "#9f7c55",
  sun           = "#c19b76",
  purple        = "#8f5b3c",
  orange        = "#986649",
  cyan          = "#5a3a25",
  statusline_bg = "#e6c0a1",
  lightbg       = "#f7d5b7",
  pmenu_bg      = "#8f5b3c",
  folder_bg     = "#5a3a25",
}
M.base_16 = {
  base00 = "#F5DCC6",
  base01 = "#F5DCC6",
  base02 = "#e6c0a1",
  base03 = "#9e4234",
  base04 = "#a1694d",
  base05 = "#9A4235",
  base06 = "#45373C",
  base07 = "#45373C",
  base08 = "#ab4637",
  base09 = "#8f5b3c",
  base0A = "#c4835a",
  base0B = "#447028",
  base0C = "#a1694d",
  base0D = "#426A79",
  base0E = "#a1694d",
  base0F = "#45373C",
}

local heading_groups = {}
for i = 1, 6 do
  heading_groups["RenderMarkdownH" .. i .. "Bg"] = { bg = M.base_30.black2, fg = M.base_16.base0D, bold = true}
end

M.type = "light"
M.polish_hl = {
  defaults = heading_groups,
  statusline = {
    St_cwd_icon      = { fg = "#d6ac89", bg = "#f7d5b7" },
    St_cwd_text      = { fg = "#5a3a25", bg = "#f7d5b7" },
    St_cwd_sep       = { fg = "#f7d5b7", bg = "#e6c0a1" },
    ---------------------------------------------------
    St_pos_icon      = { fg = "#f5dcc6", bg = "#e6c0a1" },
    St_pos_text      = { fg = "#5a3a25", bg = "#e6c0a1" },
    St_pos_sep       = { fg = "#e6c0a1", bg = "#f7d5b7" },
    ---------------------------------------------------
    St_lspError      = { fg = "#a23a2b" },
    St_Lsp           = { fg = "#5a3a25" },
    St_lspWarning    = { fg = "#b56d62" },
    St_NormalMode = { fg = "#f5dcc6", bg = "#4e2e1f" },
    St_InsertMode = { fg = "#f5dcc6", bg = "#4e2e1f" },
  },
  tbline = {
    TbFill           = { bg = "#f7d5b7" },
    TbBufOff         = { fg = "#C09B72", bg = "#f7d5b7" },
    TbBufOn          = { fg = "#5a3a25", bg = "#f5dcc6" },
    TbBufOffClose    = { fg = "#b18781", bg = "#f7d5b7" },
    TbBufOffModified = { fg = "#b18781", bg = "#f7d5b7" },
    TbBufOnModified  = { fg = "#a23a2b", bg = "#f5dcc6" },
    TbBufOnClose     = { fg = "#a23a2b", bg = "#f5dcc6" },
  },
}

return M

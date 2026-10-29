local M = {}

M.base_30 = {
  white = "#45373C",
  darker_black = "#F2CDAC",
  black = "#e9bc88",
  black2 = "#ecb78c",
  one_bg = "#e4ae83",
  one_bg2 = "#dca679",
  one_bg3 = "#d19b6f",
  grey = "#b5804f",
  grey_fg = "#a8734a",
  light_grey = "#e3ae71",
  red = "#72828a",
  baby_pink = "#a8654e",
  pink = "#b0603a",
  line = "#d9a578",
  green = "#72828a",
  vibrant_green = "#2c4a16",
  blue = "#325666",
  yellow = "#946c38",
  sun = "#b4742c",
  purple = "#7a3f5a",
  orange = "#8a4a1c",
  cyan = "#4a5e69",
  statusline_bg = "#72828a",
  lightbg = "#e9bc88",
  pmenu_bg = "#7a4a2c",
  folder_bg = "#5a3a25",
}

M.base_16 = {
  base00 = "#f5c7a2",
  base01 = "#e8b184",
  base02 = "#d9a070",
  base03 = "#85563f",
  base04 = "#7d5240",
  base05 = "#5e3a2c",
  base06 = "#45373C",
  base07 = "#2a1d16",
  base08 = "#943528",
  base09 = "#7a4a2c",
  base0A = "#7a5010",
  base0B = "#365a1e",
  base0C = "#2f5e58",
  base0D = "#325666",
  base0E = "#7a3f5a",
  base0F = "#45373C",
}

M.type = "light"
M.polish_hl = {
  statusline = {
    St_cwd_icon = { fg = "#72828a", bg = "#e9bc88" },
    St_cwd_text = { fg = "#45373c", bg = "#e9bc88" },
    St_cwd_sep = { fg = "#e9bc88", bg = "#72828a" },
    ---------------------------------------------------
    St_pos_icon = { fg = "#e9bc88", bg = "#72828a" },
    St_pos_text = { fg = "#e9bc88", bg = "#72828a" },
    St_pos_sep = { fg = "#72828a", bg = "#e9bc88" },
    ---------------------------------------------------
    St_lspError = { fg = "#a23a2b" },
    St_Lsp = { fg = "#deb17a" },
    St_lspWarning = { fg = "#e9c193" },
  },
  tbline = {
    TbFill = { bg = "#f0d3b9" },
    TbBufOff = { fg = "#C09B72", bg = "#f0d3b9" },
    TbBufOn = { fg = "#5a3a25", bg = "#f5c7a2" },
    TbBufOnClose = { fg = "#a23a2b", bg = "#f5c7a2" },
    TbBufOffClose = { fg = "#a23a2b", bg = "#f0d3b9" },
    TbBufOnModified = { fg = "#a23a2b", bg = "#f5c7a2" },
    TbBufOffModified = { fg = "#a23a2b", bg = "#f0d3b9" },
  },
}

return M

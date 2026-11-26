package.path = os.getenv("HOME") .. "/.config/rumda/common/hypr/?.lua;" .. package.path

hl.config({
	general = {
		gaps_in = 9,
		border_size = 1,
		col = {
			active_border = "rgba(90664AFF)",
			inactive_border = "rgba(90664AFF)",
		},
	},
	decoration = {
		rounding = 0,
		active_opacity = 1.0,
		inactive_opacity = 1.0,
		shadow = {
			enabled = true,
			range = 1,
			render_power = 4,
			offset = { 9, 9 },
			color = 0xEF9B6E52,
			color_inactive = 0xEF9B6E52,
			scale = 1.0,
		},
	},
})

require("shared")()

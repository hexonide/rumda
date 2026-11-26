package.path = os.getenv("HOME") .. "/.config/rumda/common/hypr/?.lua;" .. package.path

hl.config({
	general = {
		gaps_in = 10,
		border_size = 4,
		col = {
			active_border = "rgba(F0BB90FF)",
			inactive_border = "rgba(F0BB90FF)",
		},
	},
	decoration = {
		rounding = 7,
		active_opacity = 1.0,
		inactive_opacity = 0.99,
		shadow = {
			enabled = true,
			range = 3,
			render_power = 9,
			offset = { 5, 5 },
			color = 0xAA784d37,
			color_inactive = 0xAA784d37,
			scale = 1,
		},
	},
})

require("shared")()

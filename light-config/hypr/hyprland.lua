package.path = os.getenv("HOME") .. "/.config/rumda/common/hypr/?.lua;" .. package.path

hl.config({
	general = {
		gaps_in = 9,
		border_size = 3,
		col = {
			active_border = "rgba(f2bc88FF)",
			inactive_border = "rgba(f2bc88FF)",
		},
	},
	decoration = {
		rounding = 7,
		active_opacity = 1.0,
		inactive_opacity = 0.99,
		shadow = {
			enabled = true,
			range = 7,
			render_power = 4,
			offset = { 5, 5 },
			color = 0xBB784d37,
			color_inactive = 0xBB784d37,
			scale = 1.0,
		},
	},
})

require("shared")()

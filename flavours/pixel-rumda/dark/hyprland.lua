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
			render_power = 12,
			offset = { 9, 9 },
			color = 0xCC784D37,
			scale = 1.0,
		},
	},
})

require("shared")({ fakeElastic = { { 0.68, -0.1 }, { 0.265, 1 } } })

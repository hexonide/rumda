package.path = os.getenv("HOME") .. "/.config/rumda/common/hypr/?.lua;" .. package.path

hl.on("hyprland.start", function()
	hl.exec_cmd("sleep 2 && hyprctl reload &disown")
end)

hl.config({
	general = {
		gaps_in = 9,
		border_size = 3,
		col = {
			active_border = "rgba(784d37FF)",
			inactive_border = "rgba(784d37FF)",
		},
	},
	decoration = {
		rounding = 7,
		active_opacity = 1.0,
		inactive_opacity = 1.00,
		shadow = {
			enabled = false,
			range = 5,
			render_power = 4,
			offset = { 3, 4 },
			color = 0xCC7B5541,
			color_inactive = 0xCB7B5541,
			scale = 1.0,
		},
	},
})

require("shared")()

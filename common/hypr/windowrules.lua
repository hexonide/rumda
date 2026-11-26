hl.window_rule({
	match = { class = ".*" },
	suppress_event = "maximize",
})

hl.window_rule({
	match = {
		class = "^$",
		title = "^$",
		xwayland = true,
		float = true,
		fullscreen = false,
		pin = false,
	},
	no_focus = true,
})

hl.window_rule({
	name = "firefox-pip",
	match = {
		class = "^(org\\.mozilla\\.firefox)$",
		title = "^(Picture-in-Picture)$",
	},
	float = true,
	pin = true,
	size = "480 270",
	move = "(monitor_w-window_w-20) 20",
	border_size = 0,
	no_shadow = true,
})

hl.window_rule({
	match = { class = "feh" },
	float = true,
	center = true,
})

hl.window_rule({
	match = { class = "^com\\.jaoushingan\\.WaydroidHelper\\.KeyMapper.*$" },
	border_size = 1,
})
hl.window_rule({
	match = { class = "^com\\.jaoushingan\\.WaydroidHelper\\.KeyMapper.*$" },
	no_shadow = true,
})
hl.window_rule({
	match = { class = "^com\\.jaoushingan\\.WaydroidHelper\\.KeyMapper.*$" },
	rounding = 0,
})

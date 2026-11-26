require("keybinds")
require("environment")
require("windowrules")

return function(opts)
	opts = opts or {}

	hl.config({
		general = {
			gaps_out = { top = 45, right = 40, bottom = 45, left = 40 },
			allow_tearing = true,
			layout = "dwindle",
		},
	})

	hl.config({
		decoration = {
			blur = {
				enabled = false,
				size = 1,
				passes = 2,
				vibrancy = 0.1696,
			},
		},
	})

	hl.config({
		animations = {
			enabled = true,
		},
	})

	hl.curve("easeOutQuint", { type = "bezier", points = { { 0.23, 1 }, { 0.32, 1 } } })
	hl.curve("easeInOutCubic", { type = "bezier", points = { { 0.65, 0.05 }, { 0.36, 1 } } })
	hl.curve("linear", { type = "bezier", points = { { 0, 0 }, { 1, 1 } } })
	hl.curve("almostLinear", { type = "bezier", points = { { 0.5, 0.5 }, { 0.75, 1.0 } } })
	hl.curve("quick", { type = "bezier", points = { { 0.15, 0 }, { 0.1, 1 } } })
	hl.curve("overshoot", { type = "bezier", points = { { 0.05, 0.9 }, { 0.1, 1.1 } } })
	hl.curve("fakeElastic", { type = "bezier", points = { { 0.68, 0.5 }, { 0.265, 1 } } })
	hl.curve("xfcBezier", { type = "bezier", points = { { 0.1, 0.9 }, { 0.1, 1.03 } } })

	hl.animation({ leaf = "global", enabled = true, speed = 10, bezier = "default" })
	hl.animation({ leaf = "border", enabled = true, speed = 1.39, bezier = "easeOutQuint" })
	hl.animation({ leaf = "windows", enabled = true, speed = 4.79, bezier = "easeOutQuint" })
	hl.animation({ leaf = "windowsIn", enabled = true, speed = 4, bezier = "default", style = "slide bottom" })
	hl.animation({ leaf = "windowsOut", enabled = true, speed = 8, bezier = "default", style = "slide top" })
	hl.animation({ leaf = "windowsMove", enabled = true, speed = 3, bezier = "fakeElastic", style = "slide" })
	hl.animation({ leaf = "fadeIn", enabled = true, speed = 1.73, bezier = "almostLinear" })
	hl.animation({ leaf = "fadeOut", enabled = true, speed = 1.46, bezier = "almostLinear" })
	hl.animation({ leaf = "fade", enabled = true, speed = 3.03, bezier = "quick" })
	hl.animation({ leaf = "layers", enabled = true, speed = 3.81, bezier = "easeOutQuint" })
	hl.animation({ leaf = "layersIn", enabled = true, speed = 4, bezier = "easeOutQuint", style = "fade" })
	hl.animation({ leaf = "layersOut", enabled = true, speed = 1.5, bezier = "linear", style = "fade" })
	hl.animation({ leaf = "fadeLayersIn", enabled = true, speed = 1.79, bezier = "almostLinear" })
	hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 1.39, bezier = "almostLinear" })
	hl.animation({ leaf = "workspaces", enabled = true, speed = 4, bezier = "xfcBezier" })

	hl.config({
		dwindle = {
			preserve_split = true,
		},
	})

	hl.config({
		master = {
			new_status = "master",
		},
	})

	hl.config({
		misc = {
			force_default_wallpaper = 0,
			disable_hyprland_logo = true,
			vrr = 0,
		},
	})

	hl.config({
		input = {
			kb_layout = "us, ara",
			kb_variant = "",
			kb_model = "",
			kb_options = "grp:win_space_toggle",
			kb_rules = "",

			follow_mouse = 1,

			sensitivity = 0.20, -- [ -1.0 to 1.0 ]  0 means no modification.

			touchpad = {
				natural_scroll = false,
			},
		},
	})

	hl.device({
		name = "epic-mouse-v1",
		sensitivity = -0.5,
	})
end

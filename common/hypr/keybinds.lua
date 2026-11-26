-- ##################
-- ## KEYBINDINGS ###
-- ##################
local terminal = "kitty"
local fileManager = "nautilus"
local menu = '"/home/$USER/.config/rumda/scripts/rofi.sh"'
local unicode_menu =
	[[rofimoji -f "/home/$USER/.config/rofi/math_symbols.csv" --action type copy --hidden-descriptions --max-recent 0]]

-- See https://wiki.hyprland.org/Configuring/Keywords/
local mainMod = "SUPER" -- Sets "Windows" key as main modifier

-- Example binds, see https://wiki.hyprland.org/Configuring/Binds/ for more
-- hl.bind(mainMod .. " + W", hl.dsp.exec_cmd("chromium-browser --use-gl=egl --ozone-platform=wayland --enable-features=UseOzonePlatform &disown"))
-- hl.bind(mainMod .. " + F", hl.dsp.exec_cmd("/usr/bin/nautilus"))
-- hl.bind(mainMod .. " + SHIFT + Return", hl.dsp.exec_cmd("/home/$USER/.local/bin/ghosttyFLOAT.sh"))
-- hl.bind(mainMod .. " + SHIFT + Return", hl.dsp.exec_cmd("ghostty --config=~/.config/ghostty/config-float"))

-- ##################################
-- ## APPLICATION & SYSTEM ACTIONS ###
-- ##################################
hl.bind(mainMod .. " + W", hl.dsp.exec_cmd("firefox"))
hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + F", hl.dsp.exec_cmd(fileManager))
-- hl.bind(mainMod .. " + S", hl.dsp.exec_cmd([[bash -c "grim '/home/$USER/Pictures/Screenshots/$(date +%Y%m%d-%H%M%S).png'"]]))
hl.bind(
	mainMod .. " + S",
	hl.dsp.exec_cmd(
		[[bash -c 'shot="$HOME/Pictures/Screenshots/$(date +%Y%m%d-%H%M%S).png"; grim "$shot" && notify-send -a screenshot -i "$shot" "Screenshot saved" "$(basename "$shot")"']]
	)
)

hl.bind(mainMod .. " + C", hl.dsp.window.close())
-- hl.bind(mainMod .. " + M", hl.dsp.exit()) -- I hate this keybind
hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo()) -- dwindle
hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit"))
hl.bind(mainMod .. " + L", hl.dsp.exec_cmd("hyprlock"))
hl.bind(mainMod .. " + SHIFT + Return", hl.dsp.exec_cmd("ghostty"))
hl.bind(mainMod .. " + SHIFT + ALT + Q", hl.dsp.exec_cmd("hyprctl kill")) -- Forcefully zap a window

-- ####################################
-- ## WORKSPACE & WINDOW MANAGEMENT ###
-- ####################################

-- Move focus with mainMod + alt + arrow keys
hl.bind(mainMod .. " + ALT + up", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + ALT + down", hl.dsp.focus({ direction = "down" }))
hl.bind(mainMod .. " + ALT + left", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + ALT + right", hl.dsp.focus({ direction = "right" }))

-- Switch workspaces with mainMod + [0-9]
hl.bind(mainMod .. " + 1", hl.dsp.focus({ workspace = 1 }))
hl.bind(mainMod .. " + 2", hl.dsp.focus({ workspace = 2 }))
hl.bind(mainMod .. " + 3", hl.dsp.focus({ workspace = 3 }))
hl.bind(mainMod .. " + 4", hl.dsp.focus({ workspace = 4 }))
hl.bind(mainMod .. " + 5", hl.dsp.focus({ workspace = 5 }))
hl.bind(mainMod .. " + 6", hl.dsp.focus({ workspace = 6 }))
hl.bind(mainMod .. " + 7", hl.dsp.focus({ workspace = 7 }))
hl.bind(mainMod .. " + 8", hl.dsp.focus({ workspace = 8 }))
hl.bind(mainMod .. " + 9", hl.dsp.focus({ workspace = 9 }))
hl.bind(mainMod .. " + 0", hl.dsp.focus({ workspace = 10 }))

-- Move active window to a workspace with mainMod + SHIFT + [0-9]
hl.bind(mainMod .. " + SHIFT + 1", hl.dsp.window.move({ workspace = 1 }))
hl.bind(mainMod .. " + SHIFT + 2", hl.dsp.window.move({ workspace = 2 }))
hl.bind(mainMod .. " + SHIFT + 3", hl.dsp.window.move({ workspace = 3 }))
hl.bind(mainMod .. " + SHIFT + 4", hl.dsp.window.move({ workspace = 4 }))
hl.bind(mainMod .. " + SHIFT + 5", hl.dsp.window.move({ workspace = 5 }))
hl.bind(mainMod .. " + SHIFT + 6", hl.dsp.window.move({ workspace = 6 }))
hl.bind(mainMod .. " + SHIFT + 7", hl.dsp.window.move({ workspace = 7 }))
hl.bind(mainMod .. " + SHIFT + 8", hl.dsp.window.move({ workspace = 8 }))
hl.bind(mainMod .. " + SHIFT + 9", hl.dsp.window.move({ workspace = 9 }))
hl.bind(mainMod .. " + SHIFT + 0", hl.dsp.window.move({ workspace = 10 }))

-- Example special workspace (scratchpad)
hl.bind(mainMod .. " + H", hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + H", hl.dsp.window.move({ workspace = "special:magic" }))

-- Scroll through existing workspaces with mainMod + scroll
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

-- Scroll using arrows
hl.bind(mainMod .. " + right", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + left", hl.dsp.focus({ workspace = "e-1" }))

-- Move/resize windows with mainMod and arrows
hl.bind(mainMod .. " + down", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + up", hl.dsp.window.resize(), { mouse = true })
hl.bind("ALT + down", hl.dsp.window.drag(), { mouse = true })
hl.bind("ALT + up", hl.dsp.window.resize(), { mouse = true })

-- ################################
-- ## MULTIMEDIA & SYSTEM KEYS  ###
-- ################################

-- Laptop multimedia keys for volume and LCD brightness
hl.bind(
	"XF86AudioRaiseVolume",
	hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioLowerVolume",
	hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioMute",
	hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioMicMute",
	hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),
	{ locked = true, repeating = true }
)
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl s 10%+"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl s 10%-"), { locked = true, repeating = true })

-- Requires playerctl
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })

-- Media control on function keys
hl.bind("F9", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("F5", hl.dsp.exec_cmd("playerctl previous"), { locked = true })
hl.bind("F6", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("F4", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("F3", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), { locked = true, repeating = true })

-- ################################
-- ## CUSTOM / MISC BINDINGS    ###
-- ################################
hl.bind(mainMod .. " + TAB", hl.dsp.exec_cmd([[echo "toggle" > /tmp/qs-dashboard.fifo]])) -- toggle rumda dashboard < unfinished
hl.bind(mainMod .. " + Semicolon", hl.dsp.layout("splitratio -0.1"), { repeating = true })
hl.bind(mainMod .. " + Apostrophe", hl.dsp.layout("splitratio +0.1"), { repeating = true })
hl.bind(mainMod .. " + ALT + Space", hl.dsp.window.float({ action = "toggle" })) -- Float/Tile
hl.bind(mainMod .. " + D", hl.dsp.window.fullscreen({ mode = "maximized", action = "toggle" })) -- Maximize
hl.bind(mainMod .. " + Z", hl.dsp.exec_cmd([["/home/$USER/.config/rumda/scripts/zoom_toggle.sh"]]))
hl.bind(mainMod .. " + ALT + SHIFT + S", hl.dsp.exec_cmd([[bash -c "/home/$USER/.config/rumda/scripts/screenshot.sh"]]))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd([[bash -c "/home/$USER/.config/rumda/scripts/qscreen.sh"]]))
hl.bind(mainMod .. " + SHIFT + T", hl.dsp.exec_cmd([[bash -c "/home/$USER/.config/rumda/scripts/ocr.sh"]]))
hl.bind(mainMod .. " + Q", hl.dsp.exec_cmd("rofi -show drun -config .config/rumda/light-config/rofi/config.rasi"))
hl.bind(mainMod .. " + U", hl.dsp.exec_cmd(unicode_menu))
hl.bind(mainMod .. " + G", hl.dsp.exec_cmd([[bash -c "/home/$USER/.config/rumda/scripts/hypr_compact.sh"]]))
hl.bind(mainMod .. " + SHIFT + C", hl.dsp.exec_cmd("hyprpicker -a"), { description = "Color picker" })
hl.bind(mainMod .. " + SHIFT + R", hl.dsp.exec_cmd([[bash -c "/home/$USER/.config/rumda/scripts/screenrec.sh"]]))
hl.bind(
	mainMod .. " + SHIFT + ALT + R",
	hl.dsp.exec_cmd([[bash -c "/home/$USER/.config/rumda/scripts/screenrec.sh region"]])
)
-- hl.bind("grave", hl.dsp.exec_cmd("ydotool click 0x41"))
-- hl.bind("grave", hl.dsp.exec_cmd("ydotool click 0x81"), { release = true })

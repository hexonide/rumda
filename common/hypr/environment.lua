-- ############################
-- ## ENVIRONMENT VARIABLES ###
-- ############################

-- See https://wiki.hyprland.org/Configuring/Environment-variables/
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")
-- default browser
hl.env("BROWSER", "firefox")
hl.env("YDOTOOL_SOCKET", "/run/ydotoold/socket")

-- ###############
-- ## MONITORS ###
-- ###############
-- See https://wiki.hyprland.org/Configuring/Monitors/
hl.monitor({
	output = "",
	mode = "preferred",
	position = "auto",
	scale = 1,
})

-- ################
-- ## AUTOSTART ###
-- ################

-- Autostart necessary processes (like notifications daemons, status bars, etc.)
-- Or execute your favorite apps at launch like this:

hl.on("hyprland.start", function()
	hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
	hl.exec_cmd("quickshell -p .config/rumda/common/quickshell/shell.qml &disown")
	hl.exec_cmd("/home/$USER/.config/rumda/scripts/wall.sh light")
	hl.exec_cmd("/home/$USER/.config/rumda/scripts/hyprtheme.sh light")
	hl.exec_cmd("/home/$USER/.config/rumda/scripts/run_reminders.sh >/dev/null 2>&1")
end)

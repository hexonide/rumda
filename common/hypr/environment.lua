hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")
hl.env("BROWSER", "firefox")
hl.env("YDOTOOL_SOCKET", "/run/ydotoold/socket")

hl.monitor({
	output = "",
	mode = "preferred",
	position = "auto",
	scale = 1,
})

hl.on("hyprland.start", function()
	hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
	hl.exec_cmd("quickshell -p .config/rumda/common/quickshell/shell.qml &disown")
	hl.exec_cmd("/home/$USER/.config/rumda/scripts/wall.sh light")
	hl.exec_cmd("/home/$USER/.config/rumda/scripts/hyprtheme.sh light")
	hl.exec_cmd("/home/$USER/.config/rumda/scripts/run_reminders.sh >/dev/null 2>&1")
end)

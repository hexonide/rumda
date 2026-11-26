hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")
hl.env("BROWSER", "firefox")
hl.env("YDOTOOL_SOCKET", "/run/ydotoold/socket")

hl.monitor({
	output = "",
	mode = "preferred",
	position = "auto",
	scale = 1,
})

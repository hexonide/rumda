import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Services.UPower
import Quickshell.Services.SystemTray
import Quickshell.Services.Pipewire
import Quickshell.Services.Mpris
import Qt5Compat.GraphicalEffects
import qs.dark.config
import qs.dark.barModules

Rectangle {
  Layout.fillWidth: true
  Layout.rightMargin: 1
  Layout.preferredHeight: clockModule.implicitHeight + 12
  color: "transparent"

  Behavior on Layout.preferredHeight {
    NumberAnimation { duration: 1000; easing.type: Easing.InOutQuart }
  }

  ColumnLayout {
    id: clockModule
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.top: parent.top
    anchors.topMargin: 25
    spacing: 9

    ClockModule {}
    VolumeControl {}
    CpuRamIndicator {}
  }
}

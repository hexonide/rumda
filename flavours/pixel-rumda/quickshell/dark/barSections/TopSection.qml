import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
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

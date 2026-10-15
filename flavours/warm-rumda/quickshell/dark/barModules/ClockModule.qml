import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.dark.config

Rectangle {
  id: root

  property string currentHours: Qt.formatDateTime(new Date(), "hh")
  property string currentMinutes: Qt.formatDateTime(new Date(), "mm")
  property string currentDay: Qt.formatDateTime(new Date(), "dd")
  property string currentMonth: Qt.formatDateTime(new Date(), "MM")
  property bool expanded: false

  Layout.alignment: Qt.AlignHCenter
  Layout.preferredHeight: expanded ? 80 : 45
  width: 30
  radius: Config.innerBModulesRadius
  border.width: 1
  border.color: Colors.borderColor
  color: Colors.moduleBG

  Behavior on Layout.preferredHeight {
    NumberAnimation {
      duration: 250
      easing.type: Easing.InOutQuad
    }
  }

  Timer {
    interval: 1000
    running: true
    repeat: true
    onTriggered: {
      root.currentHours = Qt.formatDateTime(new Date(), "hh");
      root.currentMinutes = Qt.formatDateTime(new Date(), "mm");
    }
  }

  Timer {
    interval: 60000
    running: true
    repeat: true
    onTriggered: {
      root.currentDay = Qt.formatDateTime(new Date(), "dd");
      root.currentMonth = Qt.formatDateTime(new Date(), "MM");
    }
  }

  Process {
    id: notifProcess
    command: ["notify-send", "-i", Config.profilePath, Qt.formatDateTime(new Date(), "dddd, d MMMM yyyy"), Qt.formatDateTime(new Date(), "hh:mm AP")]
    running: false
  }

  Loader {
    anchors.centerIn: parent
    sourceComponent: root.expanded ? dateComponent : clockComponent
  }

  Component {
    id: clockComponent
    ColumnLayout {
      anchors.centerIn: parent
      spacing: 4
      Text {
        Layout.alignment: Qt.AlignHCenter
        text: root.currentHours
        color: Colors.accent2Color
        font.family: "Dogica Pixel"
        font.pixelSize: 9
      }
      Text {
        Layout.alignment: Qt.AlignHCenter
        text: root.currentMinutes
        color: Colors.accent2Color
        font.family: "Dogica Pixel"
        font.pixelSize: 9
      }
    }
  }

  Component {
    id: dateComponent
    ColumnLayout {
      anchors.centerIn: parent
      spacing: 4
      Text {
        Layout.alignment: Qt.AlignHCenter
        text: root.currentDay
        color: Colors.accent2Color
        font.family: "Dogica Pixel"
        font.pixelSize: 9
      }
      Text {
        Layout.alignment: Qt.AlignHCenter
        text: root.currentMonth
        color: Colors.accent2Color
        font.family: "Dogica Pixel"
        font.pixelSize: 9
      }
    }
  }

  MouseArea {
    anchors.fill: parent
    cursorShape: Qt.PointingHandCursor
    hoverEnabled: true
    onEntered: root.expanded = !root.expanded
    onExited: root.expanded = !root.expanded
    onClicked: notifProcess.running = true
  }
}

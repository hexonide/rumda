import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.light.config
import qs.light.barModules

Rectangle {
  id: root

  property real cpuUsage: 0
  property real ramUsage: 0

  Layout.alignment: Qt.AlignHCenter
  width: 30
  height: 60
  radius: Config.innerBModulesRadius
  color: Colors.moduleBG
  border.width: 1
  border.color: Colors.borderColor

  Rectangle {
    anchors.top: parent.top
    anchors.bottom: parent.bottom
    anchors.left: parent.left
    anchors.bottomMargin: -Config.innerBMSoffsetY
    implicitWidth: parent.implicitWidth + Config.innerBMSoffsetX
    z: -99
    color: Colors.shadowColorBM
    radius: Config.innerBMSRadius
  }

  Process {
    id: cpuProcess
    command: ["sh", "-c", "top -bn1 | grep '%Cpu(s):' | awk '{print $2}' | sed 's/%us,//'"]
    running: true
    stdout: SplitParser {
      onRead: data => {
        let v = parseFloat(data.trim());
        if (!isNaN(v)) root.cpuUsage = Math.round(v);
      }
    }
  }

  Process {
    id: ramProcess
    command: ["sh", "-c", "free | grep Mem: | awk '{printf \"%.0f\", ($2-$7)/$2*100}'"]
    running: true
    stdout: SplitParser {
      onRead: data => {
        let v = parseInt(data.trim());
        if (!isNaN(v)) root.ramUsage = v;
      }
    }
  }

  Timer {
    interval: 1000
    running: true
    repeat: true
    onTriggered: {
      cpuProcess.running = true;
      ramProcess.running = true;
    }
  }

  ColumnLayout {
    anchors.centerIn: parent
    spacing: 2

    RadialIndicator {
      Layout.alignment: Qt.AlignHCenter
      percent: root.cpuUsage
      indicatorColor: Colors.accentColor
      backgroundColor: Colors.indicatorBGColor
      size: 24
    }

    RadialIndicator {
      Layout.alignment: Qt.AlignHCenter
      percent: root.ramUsage
      indicatorColor: Colors.accent2Color
      backgroundColor: Colors.indicatorBGColor
      size: 24
    }
  }
}

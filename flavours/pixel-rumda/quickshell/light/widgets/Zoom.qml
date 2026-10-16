import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.light.config

Scope {
  id: root

  property real holeRadius: Config.zoomHoleRadius
  property real zoomLevel: Config.zoomMin
  property real cursorX: 0
  property real cursorY: 0

  function setZoom(value) {
    zoomLevel = Math.max(Config.zoomMin, Math.min(Config.zoomMax, value));
    Quickshell.execDetached(["hyprctl", "keyword", "cursor:zoom_factor", String(zoomLevel)]);
  }

  function toggle() {
    if (overlay.visible) {
      overlay.visible = false;
      setZoom(1.0);
    } else {
      holeRadius = Config.zoomHoleRadius;
      overlay.visible = true;
    }
  }

  IpcHandler {
    target: "zoom"

    function toggle(): void {
    root.toggle();
  }
  }

    PanelWindow {
      id: overlay
      visible: false
      color: "transparent"
      exclusionMode: ExclusionMode.Ignore
      WlrLayershell.layer: WlrLayer.Overlay
      WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

      anchors {
        top: true
        bottom: true
        left: true
        right: true
      }

      Item {
        anchors.fill: parent
        focus: true
        Keys.onEscapePressed: root.toggle()

        Canvas {
          id: canvas
          anchors.fill: parent
          renderTarget: Canvas.FramebufferObject

          property real darkness: Config.zoomDarkness
          property color tint: Colors.zoomTint
          property real feather: Config.zoomFeather

          onDarknessChanged: requestPaint()
          onTintChanged: requestPaint()
          onFeatherChanged: requestPaint()

          onPaint: {
            var ctx = getContext("2d");
            var edge = Math.max(0, Math.min(0.999, 1 - feather));
            var steps = 24;

            ctx.globalCompositeOperation = "source-over";
            ctx.clearRect(0, 0, width, height);
            ctx.fillStyle = Qt.rgba(tint.r, tint.g, tint.b, darkness);
            ctx.fillRect(0, 0, width, height);

            ctx.globalCompositeOperation = "destination-out";
            var g = ctx.createRadialGradient(root.cursorX, root.cursorY, 0, root.cursorX, root.cursorY,
                                             root.holeRadius);


            g.addColorStop(0, "rgba(0, 0, 0, 1)");
            for (var i = 0; i <= steps; i++) {
              var t = i / steps;
              var eased = t * t * (3 - 2 * t);
              g.addColorStop(edge + (1 - edge) * t, "rgba(0, 0, 0, " + (1 - eased) + ")");
            }
            ctx.fillStyle = g;
            ctx.fillRect(0, 0, width, height);
          }
        }

        MouseArea {
          anchors.fill: parent
          hoverEnabled: true
          acceptedButtons: Qt.NoButton

          onPositionChanged: mouse => {
            root.cursorX = mouse.x;
            root.cursorY = mouse.y;
            canvas.requestPaint();
          }

          onWheel: wheel => {
            var steps = wheel.angleDelta.y / 120;
            if (wheel.modifiers & Qt.ControlModifier) {
              root.holeRadius = Math.max(Config.zoomMinRadius, Math.min(Config.zoomMaxRadius, root.holeRadius
                                                                        + steps * Config.zoomRadiusStep));
              canvas.requestPaint();
            } else {
              root.setZoom(root.zoomLevel + steps * Config.zoomStep);
            }
          }
        }
      }
    }
  }

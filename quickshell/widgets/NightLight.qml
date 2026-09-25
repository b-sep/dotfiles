import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.common
import qs.components

// hyprsunset night light; hidden while the hyprsunset daemon isn't reachable.
// Left = popup (on/off switch + tone slider), right = quick toggle, scroll = tone.
BarButton {
    id: root

    readonly property int minTemp: 2500
    readonly property int maxTemp: 6000

    property bool available: false
    // On/off is hyprsunset's identity flag; the temperature is the tone. While
    // off, the tone only lives here and is sent when turning on.
    property bool night: false
    property int temperature: 4000
    property bool synced: false

    // Slider goes left = neutral, right = warmer.
    readonly property real toneValue: (maxTemp - temperature) / (maxTemp - minTemp)

    function setNight(on) {
        // Setting a temperature also clears identity in hyprsunset.
        var args = on ? ["temperature", String(temperature)] : ["identity", "true"]
        Quickshell.execDetached(["hyprctl", "hyprsunset"].concat(args))
        night = on
    }

    function setTone(v) {
        var t = Math.round((maxTemp - Math.max(0, Math.min(1, v)) * (maxTemp - minTemp)) / 100) * 100
        if (t === temperature) return
        temperature = t
        if (night) Quickshell.execDetached(["hyprctl", "hyprsunset", "temperature", String(t)])
    }

    visible: available
    text: Theme.icon(0xF050E)
    color: night ? Theme.yellow : Theme.fg
    tooltip: night ? "Luz noturna " + Math.round(toneValue * 100) + "% (" + temperature + "K)" : "Luz noturna"

    onClicked: button => {
        if (button === Qt.RightButton) setNight(!night)
        else popup.toggle()
    }
    onWheel: delta => setTone(toneValue + (delta > 0 ? 0.05 : -0.05))

    Process {
        id: check
        command: ["sh", "-c", "hyprctl hyprsunset identity get && hyprctl hyprsunset temperature"]
        stdout: StdioCollector {
            onStreamFinished: {
                var m = text.match(/^\s*(true|false)\s+(\d+)/)
                root.available = m !== null
                if (!m) return
                root.night = m[1] === "false"
                // While off, keep the locally picked tone instead of the daemon's.
                if (root.night || !root.synced) root.temperature = parseInt(m[2])
                root.synced = true
            }
        }
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: check.running = true
    }

    BarPopup {
        id: popup
        anchorItem: root
        spacing: 12

        Item { implicitWidth: 320; implicitHeight: 0 }

        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            SectionLabel {
                Layout.fillWidth: true
                text: "Luz noturna"
            }

            // On/off switch.
            Rectangle {
                implicitWidth: 40
                implicitHeight: 20
                color: root.night ? Theme.yellow : Theme.bgAlt

                Rectangle {
                    x: root.night ? parent.width - width - 3 : 3
                    anchors.verticalCenter: parent.verticalCenter
                    width: 14
                    height: 14
                    color: root.night ? Theme.bg : Theme.muted
                    Behavior on x { NumberAnimation { duration: 120 } }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.setNight(!root.night)
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            Slider {
                Layout.fillWidth: true
                value: root.toneValue
                dimmed: !root.night
                onMoved: v => root.setTone(v)
            }

            Text {
                Layout.preferredWidth: 56
                horizontalAlignment: Text.AlignRight
                text: Math.round(root.toneValue * 100) + "%"
                color: Theme.muted
                font.family: Theme.font
                font.pixelSize: Theme.popupSmallSize + 1
            }
        }
    }
}

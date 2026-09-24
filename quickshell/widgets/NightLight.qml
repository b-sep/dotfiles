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

    readonly property int offTemp: 6500
    readonly property int minTemp: 2500
    readonly property int maxTemp: 6000

    property bool available: false
    property int temperature: offTemp
    // Tone applied when turning on; follows the live temperature while on.
    property int nightTemp: 4000
    readonly property bool night: temperature < maxTemp + 1

    // Slider goes left = neutral, right = warmer.
    readonly property real toneValue: (maxTemp - nightTemp) / (maxTemp - minTemp)

    // Off sets a neutral 6500K instead of `identity`: identity keeps reporting the
    // last temperature, so the state would read back as still on.
    function apply(temp) {
        if (temp === temperature) return
        Quickshell.execDetached(["hyprctl", "hyprsunset", "temperature", String(temp)])
        temperature = temp
    }

    function setNight(on) { apply(on ? nightTemp : offTemp) }

    function setTone(v) {
        var t = Math.round((maxTemp - Math.max(0, Math.min(1, v)) * (maxTemp - minTemp)) / 100) * 100
        nightTemp = t
        if (night) apply(t)
    }

    visible: available
    text: Theme.icon(0xF050E)
    color: night ? Theme.yellow : Theme.fg
    tooltip: night ? "Luz noturna " + temperature + "K" : "Luz noturna"

    onClicked: button => {
        if (button === Qt.RightButton) setNight(!night)
        else popup.toggle()
    }
    onWheel: delta => setTone(toneValue + (delta > 0 ? 0.05 : -0.05))

    Process {
        id: check
        command: ["hyprctl", "hyprsunset", "temperature"]
        stdout: StdioCollector {
            onStreamFinished: {
                var m = text.match(/^\s*(\d+)/)
                root.available = m !== null
                if (!m) return
                root.temperature = parseInt(m[1])
                if (root.night) root.nightTemp = root.temperature
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
                text: root.nightTemp + "K"
                color: Theme.muted
                font.family: Theme.font
                font.pixelSize: Theme.popupSmallSize + 1
            }
        }
    }
}

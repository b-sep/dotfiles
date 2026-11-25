import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.common
import qs.components

// Power menu: shutdown, reboot, suspend.
BarButton {
    id: root

    readonly property var actions: [
        { label: "Desligar", icon: 0xF0425, accent: Theme.red, command: ["systemctl", "poweroff"] },
        { label: "Reiniciar", icon: 0xF0709, accent: Theme.yellow, command: ["systemctl", "reboot"] },
        { label: "Suspender", icon: 0xF0904, accent: Theme.blue, command: ["systemctl", "suspend"] }
    ]

    text: Theme.icon(0xF0425)
    tooltip: "Energia"

    onClicked: popup.toggle()

    BarPopup {
        id: popup
        anchorItem: root
        spacing: 8

        SectionLabel {
            Layout.minimumWidth: 200
            text: "Energia"
        }

        Repeater {
            model: root.actions

            Item {
                id: option
                required property var modelData

                Layout.fillWidth: true
                implicitHeight: 34

                Rectangle {
                    anchors.fill: parent
                    color: optionMouse.containsMouse ? option.modelData.accent : Theme.fg
                    opacity: optionMouse.containsMouse ? 0.12 : 0
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 8
                    anchors.rightMargin: 8
                    spacing: 10

                    Text {
                        text: Theme.icon(option.modelData.icon)
                        color: optionMouse.containsMouse ? option.modelData.accent : Theme.fg
                        font.family: Theme.font
                        font.pixelSize: Theme.popupFontSize + 2
                    }

                    Text {
                        Layout.fillWidth: true
                        text: option.modelData.label
                        color: optionMouse.containsMouse ? Theme.fgBright : Theme.fg
                        font.family: Theme.font
                        font.pixelSize: Theme.popupSmallSize + 1
                    }
                }

                MouseArea {
                    id: optionMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        popup.close()
                        Quickshell.execDetached(option.modelData.command)
                    }
                }
            }
        }
    }
}

import QtQuick
import Quickshell
import Quickshell.Services.SystemTray
import qs.common
import qs.components

// System tray as a drawer: icons slide out on hover, click the chevron to pin it open.
// Tray icons: left = activate, middle = secondary activate, right = menu.
Row {
    id: root

    property bool pinned: false
    readonly property bool expanded: pinned || hover.hovered

    visible: SystemTray.items.values.length > 0

    HoverHandler { id: hover }

    // Some apps (e.g. Spotify) pass "name?path=/dir" icons that the icon provider can't resolve.
    function resolveIcon(item) {
        var icon = item.icon ?? ""
        var sep = icon.indexOf("?path=")
        if (sep === -1) return icon
        var dir = icon.substring(sep + 6)
        var full = icon.substring(0, sep)
        return "file://" + dir + "/" + full.substring(full.lastIndexOf("/") + 1) + ".png"
    }

    BarButton {
        text: Theme.icon(root.expanded ? 0xF0142 : 0xF0141)
        pixelSize: Theme.fontSize
        color: Theme.muted
        fixedWidth: 24
        tooltip: root.pinned ? "Recolher bandeja" : "Fixar bandeja"
        onClicked: root.pinned = !root.pinned
    }

    Item {
        implicitWidth: root.expanded ? icons.implicitWidth : 0
        implicitHeight: Theme.barHeight
        clip: true
        Behavior on implicitWidth { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }

        Row {
            id: icons
            anchors.right: parent.right

            Repeater {
                model: SystemTray.items

                Item {
                    id: slot
                    required property SystemTrayItem modelData

                    implicitWidth: 32
                    implicitHeight: Theme.barHeight

                    Rectangle {
                        anchors.fill: parent
                        color: Theme.fg
                        opacity: mouse.containsMouse ? 0.08 : 0
                    }

                    Image {
                        anchors.centerIn: parent
                        width: 20
                        height: 20
                        sourceSize.width: 40
                        sourceSize.height: 40
                        source: root.resolveIcon(slot.modelData)
                        smooth: true
                    }

                    MouseArea {
                        id: mouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
                        onClicked: m => {
                            if (m.button === Qt.MiddleButton) {
                                slot.modelData.secondaryActivate()
                            } else if (m.button === Qt.RightButton || slot.modelData.onlyMenu) {
                                if (slot.modelData.hasMenu) {
                                    var pos = slot.mapToItem(null, 0, slot.height + Theme.popupGap)
                                    slot.modelData.display(slot.QsWindow.window, pos.x, pos.y)
                                }
                            } else {
                                slot.modelData.activate()
                            }
                        }
                        onWheel: w => slot.modelData.scroll(w.angleDelta.y, false)
                    }
                }
            }
        }
    }
}

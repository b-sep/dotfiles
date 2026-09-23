import QtQuick
import Quickshell
import qs.common

// Single tooltip shared by every BarButton; shows under the hovered item.
PopupWindow {
    id: tip

    readonly property Item target: Ui.tooltipTarget

    anchor.item: target
    anchor.rect.x: 0
    anchor.rect.y: 0
    anchor.rect.width: target ? target.width : 0
    anchor.rect.height: target ? target.height + Theme.popupGap : 0
    anchor.edges: Edges.Bottom
    anchor.gravity: Edges.Bottom
    anchor.adjustment: PopupAdjustment.Slide

    visible: target !== null && target.tooltip !== "" && Ui.activePopup === null
    color: "transparent"
    implicitWidth: label.implicitWidth + 16
    implicitHeight: label.implicitHeight + 10

    Rectangle {
        anchors.fill: parent
        color: Theme.bg
        border.color: Theme.border
        border.width: 1

        Text {
            id: label
            anchors.centerIn: parent
            text: tip.target ? tip.target.tooltip : ""
            color: Theme.fg
            font.family: Theme.font
            font.pixelSize: Theme.smallSize + 1
        }
    }
}

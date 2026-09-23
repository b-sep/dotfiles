import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.common

// Card that drops below its bar widget. Only one is open at a time (Ui.activePopup).
// grabFocus makes it a grabbing xdg popup: the compositor dismisses it on any
// click outside, while clicks inside reach the content normally.
PopupWindow {
    id: popup

    required property Item anchorItem
    property bool open: false
    property int padding: Theme.popupPadding
    property int spacing: 14
    default property alias content: body.data

    // The outside click that dismisses the popup can also land on the bar button
    // that opened it; ignore a toggle right after a dismissal so it stays closed.
    property real closedAt: 0

    function toggle() {
        if (!open && Date.now() - closedAt < 300) return
        open = !open
    }
    function close() { open = false }

    onOpenChanged: {
        if (open) Ui.activePopup = popup
        else {
            closedAt = Date.now()
            if (Ui.activePopup === popup) Ui.activePopup = null
        }
    }

    // Dismissed by the compositor (outside click) → sync our state.
    onVisibleChanged: if (!visible && open) open = false

    Connections {
        target: Ui
        function onActivePopupChanged() {
            if (Ui.activePopup !== popup) popup.open = false
        }
    }

    anchor.item: anchorItem
    anchor.rect.x: 0
    anchor.rect.y: 0
    anchor.rect.width: anchorItem.width
    anchor.rect.height: anchorItem.height + Theme.popupGap
    anchor.edges: Edges.Bottom
    anchor.gravity: Edges.Bottom
    anchor.adjustment: PopupAdjustment.Slide

    grabFocus: true
    visible: open
    color: "transparent"
    implicitWidth: body.implicitWidth + padding * 2
    implicitHeight: body.implicitHeight + padding * 2

    Rectangle {
        id: card
        anchors.fill: parent
        color: Theme.bg
        border.color: Theme.popupBorder
        border.width: Theme.popupBorderWidth
        focus: true
        Keys.onEscapePressed: popup.close()

        ColumnLayout {
            id: body
            x: popup.padding
            y: popup.padding
            spacing: popup.spacing
        }
    }
}

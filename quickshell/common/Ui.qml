pragma Singleton

import QtQuick
import Quickshell

// Shared bar state: one popup open at a time, and a single delayed tooltip.
Singleton {
    id: root

    property var activePopup: null

    property Item tooltipTarget: null
    property Item pendingTooltip: null

    function showTooltip(item) {
        pendingTooltip = item
        if (tooltipTarget !== null) tooltipTarget = item
        else tooltipTimer.restart()
    }

    function hideTooltip(item) {
        if (pendingTooltip === item) pendingTooltip = null
        if (tooltipTarget === item) tooltipTarget = null
    }

    Timer {
        id: tooltipTimer
        interval: 450
        onTriggered: root.tooltipTarget = root.pendingTooltip
    }
}

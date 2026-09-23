import QtQuick
import Quickshell
import Quickshell.Services.Pipewire
import qs.common
import qs.components

// Default input. Left = mute, scroll = volume, middle = audio popup.
// Highlighted while an app is recording from it.
BarButton {
    id: root

    property var audioWidget: null

    readonly property PwNode source: Pipewire.defaultAudioSource
    readonly property bool muted: source?.audio?.muted ?? true
    readonly property real volume: source?.audio?.volume ?? 0

    readonly property bool inUse: {
        var nodes = Pipewire.nodes.values
        for (var i = 0; i < nodes.length; i++) {
            var n = nodes[i]
            if (n.isStream && !n.isSink && n.audio) return true
        }
        return false
    }

    PwObjectTracker { objects: root.source ? [root.source] : [] }

    visible: source !== null
    text: Theme.icon(muted ? 0xF036D : 0xF036C)
    color: muted ? Theme.muted : inUse ? Theme.red : Theme.fg
    tooltip: "Microfone " + (muted ? "mudo" : Math.round(volume * 100) + "%") + (inUse && !muted ? " · em uso" : "")

    onClicked: button => {
        if (button === Qt.MiddleButton) audioWidget?.openPopup()
        else if (source?.audio) source.audio.muted = !source.audio.muted
    }
    onWheel: delta => {
        if (source?.audio) source.audio.volume = Math.max(0, Math.min(1, volume + (delta > 0 ? 0.05 : -0.05)))
    }
}

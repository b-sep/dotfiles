import QtQuick
import Quickshell.Services.Mpris
import qs.common
import qs.components

// MPRIS controls: previous, play/pause, next. Hidden unless a player has a
// track playing or paused.
Row {
    id: root

    readonly property var players: Mpris.players.values
    // Prefer whatever is playing; otherwise a paused player.
    readonly property MprisPlayer player: players.find(p => p.isPlaying)
        ?? players.find(p => p.playbackState === MprisPlaybackState.Paused)
        ?? null

    readonly property string title: player?.trackTitle ?? ""
    readonly property string artist: player?.trackArtist ?? ""

    visible: player !== null

    BarButton {
        text: Theme.icon(0xF04AE)
        opacity: root.player?.canGoPrevious ? 1 : 0.4
        tooltip: "Anterior"
        onClicked: root.player?.previous()
    }

    BarButton {
        text: Theme.icon(root.player?.isPlaying ? 0xF03E4 : 0xF040A)
        color: root.player?.isPlaying ? Theme.accent : Theme.fg
        tooltip: root.artist !== "" ? root.title + " — " + root.artist : root.title
        onClicked: root.player?.togglePlaying()
    }

    BarButton {
        text: Theme.icon(0xF04AD)
        opacity: root.player?.canGoNext ? 1 : 0.4
        tooltip: "Próxima"
        onClicked: root.player?.next()
    }
}

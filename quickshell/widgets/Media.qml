import QtQuick
import qs.common
import qs.components

// MPRIS controls: previous, play/pause, next. Hidden unless a player has a
// track playing or paused. Player selection lives in MediaPlayer.
Row {
    id: root

    readonly property var player: MediaPlayer.player
    readonly property string title: player?.trackTitle ?? ""
    readonly property string artist: player?.trackArtist ?? ""

    visible: player !== null
    // Breathing room before the tray chevron.
    rightPadding: 8

    BarButton {
        text: Theme.icon(0xF04AE)
        opacity: root.player?.canGoPrevious ? 1 : 0.4
        tooltip: "Anterior"
        onClicked: MediaPlayer.previous()
    }

    BarButton {
        text: Theme.icon(root.player?.isPlaying ? 0xF03E4 : 0xF040A)
        color: root.player?.isPlaying ? Theme.accent : Theme.fg
        tooltip: root.artist !== "" ? root.title + " — " + root.artist : root.title
        onClicked: MediaPlayer.playPause()
    }

    BarButton {
        text: Theme.icon(0xF04AD)
        opacity: root.player?.canGoNext ? 1 : 0.4
        tooltip: "Próxima"
        onClicked: MediaPlayer.next()
    }
}

import QtQuick
import Quickshell
import qs.common
import qs.components

// MPRIS controls: previous, play/pause, next. Hidden unless a player has a
// track playing or paused. Player selection lives in MediaPlayer.
// Left click runs the button's action; right click on any of them copies the
// current track to the clipboard.
Row {
    id: root

    readonly property var player: MediaPlayer.player
    readonly property string title: player?.trackTitle ?? ""
    readonly property string artist: player?.trackArtist ?? ""
    readonly property string track: artist !== "" ? title + " — " + artist : title

    function handle(button: int, action: var): void {
        if (button === Qt.LeftButton) action()
        else if (button === Qt.RightButton && track !== "") Quickshell.execDetached(["wl-copy", "--", track])
    }

    visible: player !== null
    // Breathing room before the tray chevron.
    rightPadding: 8

    BarButton {
        text: Theme.icon(0xF04AE)
        opacity: root.player?.canGoPrevious ? 1 : 0.4
        tooltip: "Anterior"
        onClicked: button => root.handle(button, () => MediaPlayer.previous())
    }

    BarButton {
        text: Theme.icon(root.player?.isPlaying ? 0xF03E4 : 0xF040A)
        color: root.player?.isPlaying ? Theme.accent : Theme.fg
        tooltip: root.track
        onClicked: button => root.handle(button, () => MediaPlayer.playPause())
    }

    BarButton {
        text: Theme.icon(0xF04AD)
        opacity: root.player?.canGoNext ? 1 : 0.4
        tooltip: "Próxima"
        onClicked: button => root.handle(button, () => MediaPlayer.next())
    }
}

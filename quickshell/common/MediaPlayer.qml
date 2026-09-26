pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Mpris

// The MPRIS player the bar controls, shared by the Media widget and the
// Hyprland media keys:
//   qs -c bar ipc call media playPause|next|previous
Singleton {
    id: root

    // Browsers (and Electron apps, which register as "chromium.instanceN") are
    // ignored: this is for music players like Spotify and cliamp.
    readonly property var browserPattern: /firefox|librewolf|\bzen\b|floorp|waterfox|mullvad|tor ?browser|chrom(e|ium)|brave|vivaldi|opera|\bedge\b|epiphany|qutebrowser|plasma-browser-integration/i

    function isBrowser(p) {
        return browserPattern.test([p.dbusName, p.desktopEntry, p.identity].join(" "))
    }

    readonly property var players: Mpris.players.values.filter(p => !isBrowser(p))
    // Prefer whatever is playing; otherwise a paused player.
    readonly property MprisPlayer player: players.find(p => p.isPlaying)
        ?? players.find(p => p.playbackState === MprisPlaybackState.Paused)
        ?? null

    function playPause(): void { if (player?.canTogglePlaying) player.togglePlaying() }
    function next(): void { if (player?.canGoNext) player.next() }
    function previous(): void { if (player?.canGoPrevious) player.previous() }

    IpcHandler {
        target: "media"
        function playPause(): void { root.playPause() }
        function next(): void { root.next() }
        function previous(): void { root.previous() }
    }
}

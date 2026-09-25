{ pkgs, ... }:

let
  focusedMonitor = ''hyprctl monitors -j | jq -r '.[] | select(.focused) | .name' '';

  sattyConfig = (pkgs.formats.toml { }).generate "satty.toml" {
    general = {
      initial-tool = "arrow";
      copy-command = "wl-copy";
      # Enter and Escape do nothing (satty defaults: copy and exit). Empty lists
      # are only possible in the config file, not as flags. Ctrl+S saves.
      actions-on-enter = [ ];
      actions-on-escape = [ ];
      # only the "Screenshot saved" notification from capture-screenshot
      disable-notifications = true;
    };
  };

  capture-screenshot = pkgs.writeShellApplication {
    name = "capture-screenshot";
    runtimeInputs = with pkgs; [ grim slurp satty hyprpicker wl-clipboard inotify-tools jq hyprland coreutils libnotify ];
    text = ''
      dir="''${XDG_PICTURES_DIR:-$HOME/Pictures}/Screenshots"
      mkdir -p "$dir"
      file="$dir/screenshot-$(date +%Y-%m-%d_%H-%M-%S).png"

      case "''${1:-region}" in
        region)
          # freeze the screen while the region is being picked
          hyprpicker -r -z & freeze=$!
          sleep 0.1
          geom=$(slurp -d) || { kill "$freeze"; exit 0; }
          kill "$freeze"
          grim_args=(-g "$geom")
          ;;
        full)
          grim_args=(-o "$(${focusedMonitor})")
          ;;
        *) echo "usage: capture-screenshot [region|full]" >&2; exit 1 ;;
      esac

      # always save and copy; the editor (satty) only opens on notification click
      grim "''${grim_args[@]}" "$file"
      wl-copy --type image/png <"$file"

      action=$(notify-send -a Capture -i "$file" \
        --action=default=Edit --action=edit=Edit \
        "Screenshot saved" "$file")
      if [[ "$action" == default || "$action" == edit ]]; then
        # satty's Ctrl+S only saves (hardcoded); copy every save to the clipboard.
        # $! is inotifywait's PID, killing it ends the copy loop too
        inotifywait -m -q -e close_write "$file" > >(
          while read -r _; do wl-copy --type image/png <"$file"; done
        ) &
        watcher=$!
        satty --config ${sattyConfig} --filename "$file" --output-filename "$file" || true
        kill "$watcher"
      fi
    '';
  };

  capture-record = pkgs.writeShellApplication {
    name = "capture-record";
    # gpu-screen-recorder comes from the capability wrapper in /run/wrappers
    runtimeInputs = with pkgs; [ slurp jq hyprland libnotify xdg-utils wl-clipboard coreutils ];
    text = ''
      # PID of the running recorder. Matching by process name doesn't work:
      # the kernel truncates it to 15 chars ("gpu-screen-reco").
      pidfile="''${XDG_RUNTIME_DIR:-/run/user/$UID}/capture-record.pid"

      recording() { [[ -s "$pidfile" ]] && kill -0 "$(cat "$pidfile")" 2>/dev/null; }

      # "stop" is only used by the bar button; the instance that started the
      # recording saves, notifies and copies it once the recorder exits
      if [[ "''${1:-}" == stop ]]; then
        if recording; then kill -INT "$(cat "$pidfile")"; fi
        exit 0
      fi

      # shortcuts never stop a recording, and never start a second one
      if recording; then exit 0; fi

      dir="''${XDG_VIDEOS_DIR:-$HOME/Videos}"
      mkdir -p "$dir"
      file="$dir/recording-$(date +%Y-%m-%d_%H-%M-%S).mp4"

      target=(-w "$(${focusedMonitor})")
      audio=()
      for arg in "$@"; do
        case "$arg" in
          region)
            geom=$(slurp -f "%wx%h+%x+%y") || exit 0
            target=(-w region -region "$geom")
            ;;
          full) ;;
          # desktop audio + microphone, merged into a single track
          audio) audio=(-a "default_output|default_input") ;;
          *) echo "usage: capture-record [region|full] [audio] | stop" >&2; exit 1 ;;
        esac
      done

      # tell the bar indicator (quickshell) when recording starts and stops
      bar() { qs -c bar ipc call recording set "$1" >/dev/null 2>&1 || true; }

      gpu-screen-recorder "''${target[@]}" "''${audio[@]}" -f 60 -k auto -fallback-cpu-encoding yes -o "$file" &
      pid=$!
      echo "$pid" >"$pidfile"
      bar true
      notify-send -a Capture -t 1500 "Recording started"

      # runs however the recorder ends: bar click or crash
      status=0
      wait "$pid" || status=$?
      rm -f "$pidfile"
      bar false

      if [[ -s "$file" ]]; then
        # a video can't go to the clipboard as raw data; copy it as a file
        # reference, which file managers, browsers and chat apps paste as a file
        wl-copy --type text/uri-list "file://$file"
        action=$(notify-send -a Capture --action=default=Open --action=open=Open "Recording saved" "$file")
        if [[ "$action" == default || "$action" == open ]]; then xdg-open "$file"; fi
      else
        notify-send -a Capture -u critical "Recording failed" "gpu-screen-recorder exited with status $status"
      fi
    '';
  };
in {
  # gpu-screen-recorder (wrapper) comes from programs.gpu-screen-recorder at system level
  home.packages = [
    capture-screenshot
    capture-record
  ];
}

{ pkgs, ... }:

# Omarchy-style screen capture:
#   - screenshot: grim + slurp (screen frozen with hyprpicker), saved + copied; satty on notification click
#   - recording:  gpu-screen-recorder (GPU encoding), region picked with slurp
# Keybinds live in hyprland.lua (Print, Shift+Print, Alt+Print, ...).

let
  focusedMonitor = ''hyprctl monitors -j | jq -r '.[] | select(.focused) | .name' '';

  capture-screenshot = pkgs.writeShellApplication {
    name = "capture-screenshot";
    runtimeInputs = with pkgs; [ grim slurp satty hyprpicker wl-clipboard jq hyprland coreutils libnotify ];
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
        # Enter overwrites the screenshot with the annotated version and copies it again
        satty --filename "$file" \
          --output-filename "$file" \
          --copy-command wl-copy \
          --early-exit \
          --actions-on-enter save-to-clipboard,save-to-file \
          --initial-tool arrow
      fi
    '';
  };

  capture-record = pkgs.writeShellApplication {
    name = "capture-record";
    # gpu-screen-recorder comes from the capability wrapper in /run/wrappers
    runtimeInputs = with pkgs; [ slurp jq hyprland libnotify xdg-utils coreutils procps ];
    text = ''
      state="''${XDG_RUNTIME_DIR:-/run/user/$UID}/capture-record.file"

      if pgrep -x gpu-screen-recorder >/dev/null; then
        pkill -INT -x gpu-screen-recorder
        while pgrep -x gpu-screen-recorder >/dev/null; do sleep 0.1; done
        file=$(cat "$state" 2>/dev/null || true)
        rm -f "$state"
        (
          action=$(notify-send -a Capture --action=open=Open "Recording saved" "$file")
          [[ "$action" == open ]] && xdg-open "$file"
        ) &
        exit 0
      fi

      dir="''${XDG_VIDEOS_DIR:-$HOME/Videos}/Recordings"
      mkdir -p "$dir"
      file="$dir/recording-$(date +%Y-%m-%d_%H-%M-%S).mp4"

      target=(-w focused)
      audio=()
      for arg in "$@"; do
        case "$arg" in
          region)
            geom=$(slurp -f "%wx%h+%x+%y") || exit 0
            target=(-w region -region "$geom")
            ;;
          full) ;;
          audio) audio=(-a default_output) ;;
          *) echo "usage: capture-record [region|full] [audio]" >&2; exit 1 ;;
        esac
      done

      echo "$file" >"$state"
      notify-send -a Capture -t 1500 "Recording" "Press the shortcut again to stop"

      # notify the bar indicator (quickshell) on start and on finish,
      # even if the recorder exits on its own
      bar() { qs -c bar ipc call recording set "$1" >/dev/null 2>&1 || true; }
      bar true
      gpu-screen-recorder "''${target[@]}" "''${audio[@]}" -f 60 -k auto -fallback-cpu-encoding yes -o "$file" || true
      bar false
    '';
  };
in {
  # gpu-screen-recorder (wrapper) comes from programs.gpu-screen-recorder at system level
  home.packages = [
    capture-screenshot
    capture-record
  ];
}

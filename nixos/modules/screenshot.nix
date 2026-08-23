{ pkgs, ... }:

let
  screenshot-menu = pkgs.writeShellScriptBin "screenshot-menu" ''
    SCREEN_DIR="$HOME/Pictures/Screenshots"
    VIDEO_DIR="$HOME/Videos/Recordings"

    PID_FILE="/tmp/gpu-screen-recorder.pid"
    FILE_FILE="/tmp/gpu-screen-recorder.file"

    mkdir -p "$SCREEN_DIR" "$VIDEO_DIR"

    timestamp() {
      date +"%Y-%m-%d_%H-%M-%S"
    }

    notify() {
      notify-send -a "Capture" "$1" "$2"
    }

    notify_open() {
      title="$1"
      file="$2"

      action=$(notify-send \
        --app-name="Capture" \
        --action="open=Open" \
        "$title" "$file")

      if [ "$action" = "open" ]; then
        xdg-open "$file" &
      fi
    }

    is_recording() {
      [[ -f "$PID_FILE" ]] && kill -0 "$(cat "$PID_FILE")" 2>/dev/null
    }

    screenshot_region() {
      file="$SCREEN_DIR/screenshot_$(timestamp).png"

      sleep 0.25
      grimblast --freeze save area "$file" &&
        wl-copy < "$file" &&
        notify_open "Screenshot saved" "$file"
    }

    screenshot_full() {
      file="$SCREEN_DIR/screenshot_$(timestamp).png"

      sleep 0.25
      grimblast --freeze save screen "$file" &&
        wl-copy < "$file" &&
        notify_open "Screenshot saved" "$file"
    }

    record_start() {
      file="$VIDEO_DIR/recording_$(timestamp).mp4"

      gpu-screen-recorder \
        -w portal \
        -f 60 \
        -fm cfr \
        -k auto \
        -o "$file" &

      pid=$!

      echo "$pid" > "$PID_FILE"
      echo "$file" > "$FILE_FILE"
    }

    record_stop() {
      if ! is_recording; then
        notify "No recording running" ""
        exit
      fi

      pid=$(cat "$PID_FILE")
      file=$(cat "$FILE_FILE")

      kill -SIGINT "$pid"

      rm -f "$PID_FILE" "$FILE_FILE"

      notify_open "Recording saved" "$file"
    }

    menu() {
      if is_recording; then
        rec="⏹ Stop recording"
      else
        rec="⏺ Record screen"
      fi

      choice=$(printf "󰹑 Screenshot region\n󰹑 Screenshot fullscreen\n%s" "$rec" \
        | walker --dmenu --maxheight 200 --minheight 200 --placeholder "Capture")

      sleep 0.25

      case "$choice" in
        *region*) screenshot_region ;;
        *fullscreen*) screenshot_full ;;
        *Record*) record_start ;;
        *Stop*) record_stop ;;
      esac
    }

    case "$1" in
      region) screenshot_region ;;
      fullscreen) screenshot_full ;;
      record)
        if is_recording; then
          record_stop
        else
          record_start
        fi
      ;;
      stop) record_stop ;;
      *) menu ;;
    esac
  '';
in {
  environment.systemPackages = with pkgs; [
    screenshot-menu
    grimblast
    gpu-screen-recorder
    wl-clipboard
    libnotify
    xdg-utils
  ];
}

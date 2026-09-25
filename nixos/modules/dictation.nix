{ pkgs, ... }:

# https://voxtype.io
#
# Local push-to-talk dictation
# the daemon runs as a user service, the keys are Hyprland binds (hotkey
# disabled here) and the text is typed into the focused window, so it works
# in any app (Claude Code / opencode in the terminal, VS Code, browser...).
#
#   F9 (hold)          push-to-talk: record while held, transcribe on release
#   Super + Ctrl + X   toggle recording
#
# Everything runs on this machine: whisper.cpp on the GPU (Vulkan), with the
# model fetched into the store at build time. No API, no `voxtype setup`.

let
  # whisper.cpp with Vulkan runs on the GTX 1070 (the nixpkgs default is CPU only)
  voxtype = pkgs.voxtype.override { vulkanSupport = true; };

  # multilingual, fast on GPU with near large-v3 accuracy.
  # URL and hash from upstream's nix/models.nix (voxtype v1.0.1).
  # The URL tracks `main`: if the file changes upstream, the build fails with
  # a hash mismatch. To update (or swap models), change the URL and run
  # `nix store prefetch-file <url>` for the new hash. If dictation misbehaves:
  # `journalctl --user -u voxtype -f`.
  model = pkgs.fetchurl {
    name = "ggml-large-v3-turbo.bin";
    url = "https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-large-v3-turbo.bin";
    hash = "sha256-H8cPd0046xaZk6w5Huo1fvR8iHV+9y7llDh5t+jivGk=";
  };

  # anything not set here uses voxtype's defaults (config/default.toml)
  config = (pkgs.formats.toml { }).generate "voxtype.toml" {
    # read by `voxtype record ...` and `voxtype status` (quickshell bar)
    state_file = "auto";

    # keys are bound in hyprland.lua
    hotkey.enabled = false;

    audio = {
      # ALSA default, which is PipeWire (services.pipewire.alsa)
      device = "default";
      max_duration_secs = 120;
      pause_media = true;
    };

    whisper = {
      model = "${model}";
      # detect between these two only. A fixed "pt" is ~2s faster per clip on
      # the 1070 (no detection pass), but turns short English phrases into
      # broken Portuguese
      language = [ "pt" "en" ];
      translate = false;
      # encode only the recorded length instead of whisper's full 30s window
      # (~2s faster per clip). Upstream: may cause repetition loops with turbo
      # models; turn off if that shows up
      context_window_optimization = true;
      # dictation is occasional: load the model (~2.4GB VRAM) when recording
      # starts, in parallel with speaking, and free it after transcribing
      on_demand_loading = true;
    };

    output = {
      # wtype (virtual keyboard); clipboard if typing fails
      mode = "type";
      fallback_to_clipboard = true;
      notification = {
        on_recording_start = false;
        on_recording_stop = false;
        on_transcription = false;
      };
    };

    # built without an OSD frontend; the quickshell bar shows the state
    osd.enabled = false;
  };
in
{
  home.packages = [ voxtype ];

  xdg.configFile."voxtype/config.toml".source = config;

  systemd.user.services.voxtype = {
    Unit = {
      Description = "Voxtype push-to-talk dictation daemon";
      Documentation = "https://voxtype.io";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" "pipewire.service" "pipewire-pulse.service" ];
      # restart on switch when the config (model, language...) changes
      X-Restart-Triggers = [ "${config}" ];
    };

    Service = {
      ExecStart = "${voxtype}/bin/voxtype daemon";
      Restart = "on-failure";
      RestartSec = 5;
    };

    Install.WantedBy = [ "graphical-session.target" ];
  };
}

{
  pkgs,
  lib,
  machine ? "desktop",
  inputs,
  ...
}: let
  voxtype = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.voxtype;
in {
  config = lib.mkIf (machine == "desktop") {
    xdg.configFile."voxtype/config.toml" = {
      force = true;
      text = ''
      state_file = "auto"

      [hotkey]
      enabled = false

      [audio]
      device = "default"
      sample_rate = 16000
      max_duration_secs = 60

      [whisper]
      model = "base.en"
      language = "en"
      translate = false
      on_demand_loading = false

      [output]
      mode = "type"
      fallback_to_clipboard = true
      type_delay_ms = 0

      [output.notification]
      on_recording_start = false
      on_recording_stop = false
      on_transcription = true

      [status]
      icon_theme = "nerd-font"
      '';
    };

    systemd.user.services.voxtype = {
      Unit = {
        Description = "Voxtype push-to-talk voice-to-text daemon";
        Documentation = "https://voxtype.io";
        PartOf = ["graphical-session.target"];
        After = ["graphical-session.target" "pipewire.service" "pipewire-pulse.service"];
      };

      Service = {
        Type = "simple";
        ExecStart = "${voxtype}/bin/voxtype daemon";
        Restart = "on-failure";
        RestartSec = 5;
      };

      Install.WantedBy = ["graphical-session.target"];
    };
  };
}

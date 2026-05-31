{ config, lib, pkgs, ... }:

let
  cfg = config.services.piBackup;

  backupScript = pkgs.writeShellApplication {
    name = "backup-to-pi";
    runtimeInputs = with pkgs; [ coreutils findutils openssh rsync ];
    text = ''
      set -euo pipefail

      PI_HOST="''${PI_HOST:-${lib.escapeShellArg cfg.piHost}}"
      PI_USER="''${PI_USER:-${lib.escapeShellArg cfg.piUser}}"
      DEST_ROOT="''${DEST_ROOT:-${lib.escapeShellArg cfg.destRoot}}"
      SRC_DIR="''${1:-${lib.escapeShellArg cfg.sourceDir}}"
      RUN_ID="$(date +%Y%m%d-%H%M%S)"
      REMOTE="''${PI_USER}@''${PI_HOST}"

      SSH_OPTS=(
        -o BatchMode=yes
        -o ConnectTimeout=${toString cfg.connectTimeout}
        -o ServerAliveInterval=10
        -o ServerAliveCountMax=2
      )

      if [[ ! -d "$SRC_DIR" ]]; then
        echo "Source directory does not exist: $SRC_DIR" >&2
        exit 2
      fi

      if ! ssh "''${SSH_OPTS[@]}" "$REMOTE" true; then
        echo "Pi is not reachable over passwordless SSH: $REMOTE" >&2
        echo "Tip: set up an SSH key with: ssh-copy-id $REMOTE" >&2
        exit 1
      fi

      ssh "''${SSH_OPTS[@]}" "$REMOTE" \
        "mkdir -p '$DEST_ROOT/latest' '$DEST_ROOT/logs' '$DEST_ROOT/manifests' '$DEST_ROOT/state'"

      LOG_FILE="/tmp/backup-to-pi-''${RUN_ID}.log"
      MANIFEST_FILE="/tmp/backup-to-pi-''${RUN_ID}.manifest"

      {
        echo "run_id=$RUN_ID"
        echo "source=$SRC_DIR"
        echo "destination=$REMOTE:$DEST_ROOT/latest"
        echo "started=$(date -Is)"
        echo
      } | tee "$LOG_FILE"

      ssh "''${SSH_OPTS[@]}" "$REMOTE" \
        "printf '%s\n' 'run_id=$RUN_ID' 'source=$SRC_DIR' 'started=$(date -Is)' > '$DEST_ROOT/state/in-progress.txt'"

      mark_failure() {
        local exit_code=$?
        {
          echo
          echo "failed=$(date -Is)"
          echo "exit_code=$exit_code"
        } | tee -a "$LOG_FILE"
        scp -q "$LOG_FILE" "$REMOTE:$DEST_ROOT/logs/''${RUN_ID}.failed.log" 2>/dev/null || true
        ssh "''${SSH_OPTS[@]}" "$REMOTE" \
          "printf '%s\n' 'run_id=$RUN_ID' 'source=$SRC_DIR' 'failed=$(date -Is)' 'exit_code=$exit_code' > '$DEST_ROOT/state/last-failure.txt'" 2>/dev/null || true
        exit "$exit_code"
      }
      trap mark_failure ERR INT TERM

      rsync -rltvh --delete --checksum --stats --partial-dir=.rsync-partial --delay-updates \
        --no-owner --no-group --no-perms \
        ${lib.concatMapStringsSep " \\\n+        " (exclude: "--exclude ${lib.escapeShellArg exclude}") cfg.excludes} \
        "$SRC_DIR"/ "$REMOTE:$DEST_ROOT/latest/" | tee -a "$LOG_FILE"

      {
        echo "run_id=$RUN_ID"
        echo "source=$SRC_DIR"
        echo "destination=$REMOTE:$DEST_ROOT/latest"
        echo "finished=$(date -Is)"
        echo
        echo "excludes:"
        ${lib.concatMapStringsSep "\n        " (exclude: "printf '  - %s\\n' ${lib.escapeShellArg exclude}") cfg.excludes}
      } > "$MANIFEST_FILE"

      {
        echo
        echo "finished=$(date -Is)"
      } | tee -a "$LOG_FILE"

      scp -q "$LOG_FILE" "$REMOTE:$DEST_ROOT/logs/''${RUN_ID}.log"
      scp -q "$MANIFEST_FILE" "$REMOTE:$DEST_ROOT/manifests/''${RUN_ID}.manifest"
      ssh "''${SSH_OPTS[@]}" "$REMOTE" \
        "printf '%s\n' '$RUN_ID' > '$DEST_ROOT/last-success.txt' && printf '%s\n' '$RUN_ID' > '$DEST_ROOT/state/last-success.txt' && rm -f '$DEST_ROOT/state/in-progress.txt' '$DEST_ROOT/state/last-failure.txt'"

      trap - ERR INT TERM

      echo "Backup complete: $RUN_ID"
      echo "Remote latest: $REMOTE:$DEST_ROOT/latest"
      echo "Remote log:    $REMOTE:$DEST_ROOT/logs/''${RUN_ID}.log"
      echo "Remote manifest: $REMOTE:$DEST_ROOT/manifests/''${RUN_ID}.manifest"
    '';
  };
in
{
  options.services.piBackup = {
    enable = lib.mkEnableOption "incremental backups to the Raspberry Pi SSD";

    user = lib.mkOption {
      type = lib.types.str;
      default = "user";
      description = "Local user that owns the SSH key used to reach the Pi.";
    };

    sourceDir = lib.mkOption {
      type = lib.types.str;
      default = "/home/user/backup-source";
      description = "Local directory to back up.";
    };

    piHost = lib.mkOption {
      type = lib.types.str;
      default = "backup-host.local";
      description = "Raspberry Pi hostname or IP address.";
    };

    piUser = lib.mkOption {
      type = lib.types.str;
      default = "backup";
      description = "SSH user on the Raspberry Pi.";
    };

    destRoot = lib.mkOption {
      type = lib.types.str;
      default = "/srv/backups/host";
      description = "Backup root on the Pi SSD.";
    };

    connectTimeout = lib.mkOption {
      type = lib.types.ints.positive;
      default = 5;
      description = "SSH connection timeout in seconds.";
    };

    excludes = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        ".cache/"
        "node_modules/"
        ".direnv/"
        "result"
        "result-*"
      ];
      description = "rsync exclude patterns.";
    };

    timer = {
      enable = lib.mkEnableOption "scheduled Pi backups";

      onCalendar = lib.mkOption {
        type = lib.types.str;
        default = "daily";
        description = "systemd OnCalendar expression for scheduled backups.";
      };

      persistent = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Run a missed scheduled backup after boot.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ backupScript ];

    systemd.services.pi-backup = {
      description = "Back up files to Raspberry Pi SSD";
      wants = [ "network-online.target" ];
      after = [ "network-online.target" ];
      path = with pkgs; [ coreutils findutils openssh rsync ];
      serviceConfig = {
        Type = "oneshot";
        User = cfg.user;
        ExecStart = "${backupScript}/bin/backup-to-pi ${lib.escapeShellArg cfg.sourceDir}";
      };
    };

    systemd.timers.pi-backup = lib.mkIf cfg.timer.enable {
      description = "Scheduled backup to Raspberry Pi SSD";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = cfg.timer.onCalendar;
        Persistent = cfg.timer.persistent;
        Unit = "pi-backup.service";
      };
    };
  };
}

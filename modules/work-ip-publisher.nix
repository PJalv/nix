{config, lib, pkgs, ...}:
with lib; let
  cfg = config.services.workIpPublisher;
  publisherScript = pkgs.writeShellScript "work-ip-publisher" ''
    set -euo pipefail

    ENDPOINT="''${WORK_IP_ENDPOINT:-https://pjalv.com/ip-registry}"
    HOST_NAME="''${WORK_IP_HOST:-work-pc}"
    ALLOWED_CIDR="''${WORK_IP_CIDR:-10.176.0.0/16}"
    TOKEN_FILE="''${WORK_IP_TOKEN_FILE:-/etc/work-ip-registry/publisher-token}"

    if [ ! -r "$TOKEN_FILE" ]; then
      echo "work-ip-publisher: token file $TOKEN_FILE not readable" >&2
      exit 1
    fi

    TOKEN=$(tr -d '[:space:]' < "$TOKEN_FILE")

    PREFSRC=$(ip -j -4 route show default | ${pkgs.jq}/bin/jq -r '.[0].prefsrc // empty')
    if [ -z "$PREFSRC" ]; then
      echo "work-ip-publisher: no default IPv4 route found" >&2
      exit 0
    fi

    if ! python3 -c "
import ipaddress, sys
addr = ipaddress.ip_address(sys.argv[1])
net = ipaddress.ip_network(sys.argv[2])
sys.exit(0 if addr in net else 1)
" "$PREFSRC" "$ALLOWED_CIDR" 2>/dev/null; then
      echo "work-ip-publisher: address $PREFSRC not in $ALLOWED_CIDR, skipping" >&2
      exit 0
    fi

    RESPONSE=$(curl -sS -o /dev/null -w "%{http_code}" \
      -X PUT \
      -H "Authorization: Bearer $TOKEN" \
      -H "Content-Type: application/json" \
      -d "{\"ipv4\":\"$PREFSRC\"}" \
      "$ENDPOINT/v1/hosts/$HOST_NAME" 2>&1) || true

    if [ "$RESPONSE" = "204" ]; then
      echo "work-ip-publisher: published $PREFSRC for $HOST_NAME"
    else
      echo "work-ip-publisher: publish failed (HTTP $RESPONSE)" >&2
      exit 1
    fi
  '';
in {
  options.services.workIpPublisher = {
    enable = mkEnableOption "Work PC IP publisher";

    endpoint = mkOption {
      type = types.str;
      default = "https://pjalv.com/ip-registry";
      description = "Base URL of the IP registry API";
    };

    hostName = mkOption {
      type = types.str;
      default = "work-pc";
      description = "Host name to register in the registry";
    };

    allowedCidr = mkOption {
      type = types.str;
      default = "10.176.0.0/16";
      description = "CIDR range that addresses must fall within";
    };

    tokenFile = mkOption {
      type = types.path;
      default = "/etc/work-ip-registry/publisher-token";
      description = "Path to the bearer token file (must be readable by root)";
    };

    interval = mkOption {
      type = types.str;
      default = "2min";
      description = "Systemd timer interval for publishing";
    };
  };

  config = mkIf cfg.enable {
    systemd.services.work-ip-publisher = {
      description = "Publish work PC IP to registry";
      after = ["network-online.target"];
      wants = ["network-online.target"];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = publisherScript;
        Environment = [
          "WORK_IP_ENDPOINT=${cfg.endpoint}"
          "WORK_IP_HOST=${cfg.hostName}"
          "WORK_IP_CIDR=${cfg.allowedCidr}"
          "WORK_IP_TOKEN_FILE=${cfg.tokenFile}"
          "PATH=/run/wrappers/bin:/nix/var/nix/profiles/default/bin:/run/current-system/sw/bin"
        ];
        PrivateTmp = true;
      };
    };

    systemd.timers.work-ip-publisher = {
      description = "Periodically publish work PC IP";
      wantedBy = ["timers.target"];
      timerConfig = {
        OnBootSec = "30s";
        OnUnitActiveSec = cfg.interval;
        Unit = "work-ip-publisher.service";
        Persistent = true;
      };
    };

  };
}

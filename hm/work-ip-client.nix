{config, lib, pkgs, ...}:
with lib; let
  cfg = config.programs.workIpClient;

  workIpAddress = pkgs.writeShellScriptBin "work-ip-address" ''
    set -euo pipefail

    ENDPOINT="''${WORK_IP_ENDPOINT:-https://pjalv.com/ip-registry}"
    HOST_NAME="''${1:-work-pc}"
    TOKEN_FILE="''${WORK_IP_TOKEN_FILE:-$HOME/.config/work-ip-registry/reader-token}"

    if [ ! -r "$TOKEN_FILE" ]; then
      echo "work-ip-address: token file $TOKEN_FILE not readable" >&2
      exit 1
    fi

    TOKEN=$(tr -d '[:space:]' < "$TOKEN_FILE")

    RESPONSE=$(curl -sf -H "Authorization: Bearer $TOKEN" "$ENDPOINT/v1/hosts/$HOST_NAME" 2>&1) || {
      echo "work-ip-address: failed to retrieve IP for $HOST_NAME" >&2
      echo "$RESPONSE" >&2
      exit 1
    }

    IPV4=$(echo "$RESPONSE" | ${pkgs.jq}/bin/jq -r '.ipv4 // empty')
    UPDATED=$(echo "$RESPONSE" | ${pkgs.jq}/bin/jq -r '.updated_at // empty')

    if [ -z "$IPV4" ]; then
      echo "work-ip-address: no ipv4 field in response" >&2
      exit 1
    fi

    # Validate it's in 10.176.0.0/16
    if ! python3 -c "
import ipaddress, sys
addr = ipaddress.ip_address(sys.argv[1])
net = ipaddress.ip_network('10.176.0.0/16')
sys.exit(0 if addr in net else 1)
" "$IPV4" 2>/dev/null; then
      echo "work-ip-address: retrieved address $IPV4 is not in 10.176.0.0/16" >&2
      exit 1
    fi

    # Warn if stale (older than 10 minutes) but do not block
    if [ -n "$UPDATED" ]; then
      NOW_EPOCH=$(date +%s)
      UPD_EPOCH=$(date -d "$UPDATED" +%s 2>/dev/null || echo 0)
      if [ "$UPD_EPOCH" -gt 0 ]; then
        AGE=$((NOW_EPOCH - UPD_EPOCH))
        if [ "$AGE" -gt 600 ]; then
          echo "work-ip-address: WARNING: record is $AGE seconds old (may be stale)" >&2
        fi
      fi
    fi

    echo "$IPV4"
  '';

  workIpProxy = pkgs.writeShellScriptBin "work-ip-proxy" ''
    set -euo pipefail

    HOST_NAME="''${1:-work-pc}"
    SSH_PORT="''${2:-22}"

    IP=$(work-ip-address "$HOST_NAME") || exit 1
    exec ${pkgs.netcat-openbsd}/bin/nc "$IP" "$SSH_PORT"
  '';
in {
  options.programs.workIpClient = {
    enable = mkEnableOption "Work IP SSH client";

    endpoint = mkOption {
      type = types.str;
      default = "https://pjalv.com/ip-registry";
      description = "Base URL of the IP registry API";
    };
  };

  config = mkIf cfg.enable {
    home.packages = [workIpAddress workIpProxy];

    programs.ssh = {
      enable = true;
      matchBlocks = {
        "work-pc" = {
          host = "work-pc";
          user = "pjalv";
          port = 22;
          proxyCommand = "${workIpProxy}/bin/work-ip-proxy work-pc %p";
          extraOptions = { StrictHostKeyChecking = "yes"; };
        };
      };
    };
  };
}

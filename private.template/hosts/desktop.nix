{lib, username ? "user", ...}: {
  networking.hostName = lib.mkDefault "desktop";

  # LAN interface: enp11s0 at 192.168.169.1/24
  # WiFi uplink: wlp10s0 (DHCP)
  # Desktop shares WiFi internet to LAN clients via NAT + dnsmasq DHCP/DNS

  networking.interfaces.enp11s0.ipv4.addresses = [
    {
      address = "192.168.169.1";
      prefixLength = 24;
    }
  ];

  services.dnsmasq = {
    enable = true;
    # Do not add 127.0.0.1 to this machine's /etc/resolv.conf. This dnsmasq
    # instance is only for LAN clients on enp11s0.
    resolveLocalQueries = false;
    settings = {
      interface = "enp11s0";
      bind-interfaces = true;
      dhcp-range = "192.168.169.100,192.168.169.200,24h";
      dhcp-option = "option:router,192.168.169.1";
      dhcp-option-force = "option:dns-server,192.168.169.1";
      no-hosts = true;
      # Forward DNS to the servers learned by NetworkManager from the uplink
      # instead of pinning dnsmasq to a public resolver.
      resolv-file = "/run/NetworkManager/no-stub-resolv.conf";
      strict-order = true;
      cache-size = 1000;
      listen-address = "192.168.169.1";
    };
  };

  # NAT masquerade: LAN clients → WiFi internet
  networking.firewall = {
    enable = true;
    extraCommands = ''
      iptables -t nat -A POSTROUTING -o wlp10s0 -s 192.168.169.0/24 -j MASQUERADE
    '';
    extraForwardRules = ''
      ip saddr 192.168.169.0/24 iifname "enp11s0" oifname "wlp10s0" accept
      ip daddr 192.168.169.0/24 iifname "wlp10s0" oifname "enp11s0" ct state established,related accept
    '';
  };

  services.piBackup = {
    enable = lib.mkDefault false;
    user = lib.mkDefault username;
    sourceDir = lib.mkDefault "/home/${username}/backup-source";
    piHost = lib.mkDefault "backup-host.local";
    piUser = lib.mkDefault "backup";
    destRoot = lib.mkDefault "/srv/backups/desktop";
    timer.enable = lib.mkDefault false;
  };
}

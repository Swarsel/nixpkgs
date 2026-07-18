{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.cloudflare-warp;
in
{
  options.services.cloudflare-warp = {
    enable = lib.mkEnableOption "Cloudflare Zero Trust client daemon";
    package = lib.mkPackageOption pkgs "cloudflare-warp" { };

    openFirewall = lib.mkEnableOption "opening UDP ports in the firewall" // {
      default = true;
    };

    rootDir = lib.mkOption {
      default = "/var/lib/cloudflare-warp";

      description = ''
        Working directory for the warp-svc daemon.
      '';

      type = lib.types.str;
    };

    udpPort = lib.mkOption {
      default = 2408;

      description = ''
        The UDP port to open in the firewall. Warp uses port 2408 by default, but fallback ports can be used
        if that conflicts with another service. See the [firewall documentation](https://developers.cloudflare.com/cloudflare-one/connections/connect-devices/warp/deployment/firewall#warp-udp-ports)
        for the pre-configured available fallback ports.
      '';

      type = lib.types.port;
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];

    networking.firewall = lib.mkIf cfg.openFirewall {
      allowedUDPPorts = [ cfg.udpPort ];
    };

    systemd.services.cloudflare-warp = {
      enable = true;
      description = "Cloudflare Zero Trust Client Daemon";
      # lsof is used by the service to determine which UDP port to bind to
      # in the case that it detects collisions.
      path = [ pkgs.lsof ];
      requires = [ "network.target" ];

      serviceConfig =
        let
          caps = [
            "CAP_NET_ADMIN"
            "CAP_NET_BIND_SERVICE"
            "CAP_SYS_PTRACE"
          ];
        in
        {
          AmbientCapabilities = caps;
          CapabilityBoundingSet = caps;
          Environment = [ "RUST_BACKTRACE=full" ];
          ExecStart = "${cfg.package}/bin/warp-svc";
          Group = "root";
          LogsDirectory = "cloudflare-warp";

          ReadWritePaths = [
            "${cfg.rootDir}"
            "/etc/resolv.conf"
          ];

          Restart = "always";
          RestartSec = 5;
          RuntimeDirectory = "cloudflare-warp";
          # See the systemd.exec docs for the canonicalized paths, the service
          # makes use of them for logging, and account state info tracking.
          # https://www.freedesktop.org/software/systemd/man/latest/systemd.exec.html#RuntimeDirectory=
          StateDirectory = "cloudflare-warp";
          Type = "simple";
          # The service needs to write to /etc/resolv.conf to configure DNS, so that file would have to
          # be world read/writable to run as anything other than root.
          User = "root";
          WorkingDirectory = cfg.rootDir;
        };

      wantedBy = [ "multi-user.target" ];
    };

    systemd.tmpfiles.rules = [
      "d ${cfg.rootDir}    - root root"
      "z ${cfg.rootDir}    - root root"
    ];
  };

  meta.maintainers = with lib.maintainers; [ treyfortmuller ];
}

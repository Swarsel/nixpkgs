{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.torrentstream;
  dataDir = "/var/lib/torrentstream/";
in
{
  options.services.torrentstream = {
    enable = lib.mkEnableOption "TorrentStream daemon";
    package = lib.mkPackageOption pkgs "torrentstream" { };

    address = lib.mkOption {
      default = "0.0.0.0";

      description = ''
        Address to listen on.
      '';

      type = lib.types.str;
    };

    openFirewall = lib.mkOption {
      default = false;

      description = ''
        Open ports in the firewall for TorrentStream daemon.
      '';

      type = lib.types.bool;
    };

    port = lib.mkOption {
      default = 5082;

      description = ''
        TorrentStream port.
      '';

      type = lib.types.port;
    };
  };

  config = lib.mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [ cfg.port ];

    systemd.services.torrentstream = {
      after = [ "network.target" ];
      description = "TorrentStream Daemon";

      environment = {
        DOWNLOAD_PATH = "%S/torrentstream";
        LISTEN_ADDR = cfg.address;
        WEB_PORT = toString cfg.port;
      };

      serviceConfig = {
        DynamicUser = true;
        ExecStart = lib.getExe cfg.package;
        Restart = "on-failure";
        StateDirectory = "torrentstream";
        UMask = "077";
      };

      wantedBy = [ "multi-user.target" ];
    };
  };
}

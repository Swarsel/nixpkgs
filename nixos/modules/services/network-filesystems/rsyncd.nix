{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.rsyncd;
  settingsFormat = pkgs.formats.iniWithGlobalSection { };
  configFile = settingsFormat.generate "rsyncd.conf" cfg.settings;
in
{
  imports = (
    map
      (
        option:
        lib.mkRemovedOptionModule [
          "services"
          "rsyncd"
          option
        ] "This option was removed in favor of `services.rsyncd.settings`."
      )
      [
        "address"
        "extraConfig"
        "motd"
        "user"
        "group"
      ]
  );

  options = {
    services.rsyncd = {

      enable = lib.mkEnableOption "the rsync daemon";

      port = lib.mkOption {
        default = 873;
        description = "TCP port the daemon will listen on.";
        type = lib.types.port;
      };

      settings = lib.mkOption {
        inherit (settingsFormat) type;
        default = { };

        description = ''
          Configuration for rsyncd. See
          {manpage}`rsyncd.conf(5)`.
        '';

        example = {
          globalSection = {
            address = "0.0.0.0";
            gid = "nobody";
            "max connections" = 4;
            uid = "nobody";
            "use chroot" = true;
          };

          sections = {
            cvs = {
              "auth users" = [
                "tridge"
                "susan"
              ];

              comment = "CVS repository (requires authentication)";
              path = "/data/cvs";
              "secrets file" = "/etc/rsyncd.secrets";
            };

            ftp = {
              comment = "whole ftp area";
              path = "/var/ftp/./pub";
            };
          };
        };
      };

      socketActivated = lib.mkOption {
        default = false;
        description = "If enabled Rsync will be socket-activated rather than run persistently.";
        type = lib.types.bool;
      };

    };
  };

  config = lib.mkIf cfg.enable {

    services.rsyncd.settings.globalSection.port = toString cfg.port;

    systemd =
      let
        serviceConfigSecurity = {
          NoNewPrivileges = "on";
          PrivateDevices = "on";
          ProtectSystem = "full";
        };
      in
      {
        services.rsync = {
          enable = !cfg.socketActivated;
          after = [ "network.target" ];
          aliases = [ "rsyncd.service" ];
          description = "fast remote file copy program daemon";

          documentation = [
            "man:rsync(1)"
            "man:rsyncd.conf(5)"
          ];

          serviceConfig = serviceConfigSecurity // {
            ExecStart = "${pkgs.rsync}/bin/rsync --daemon --no-detach --config=${configFile}";
            RestartSec = 1;
          };

          wantedBy = [ "multi-user.target" ];
        };

        services."rsync@" = {
          after = [ "network.target" ];
          description = "fast remote file copy program daemon";

          serviceConfig = serviceConfigSecurity // {
            ExecStart = "${pkgs.rsync}/bin/rsync --daemon --config=${configFile}";
            StandardError = "journal";
            StandardInput = "socket";
            StandardOutput = "inherit";
          };
        };

        sockets.rsync = {
          enable = cfg.socketActivated;
          conflicts = [ "rsync.service" ];
          description = "socket for fast remote file copy program daemon";
          listenStreams = [ (toString cfg.port) ];
          socketConfig.Accept = true;
          wantedBy = [ "sockets.target" ];
        };
      };

  };
  # TODO: socket activated rsyncd

}

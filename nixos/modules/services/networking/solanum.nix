{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    types
    ;
  cfg = config.services.solanum;

  configFile = pkgs.writeText "solanum.conf" cfg.config;
in

{

  ###### interface

  options = {

    services.solanum = {

      config = mkOption {
        default = ''
          serverinfo {
            name = "irc.example.com";
            sid = "1ix";
            description = "irc!";

            vhost = "0.0.0.0";
            vhost6 = "::";
          };

          listen {
            host = "0.0.0.0";
            port = 6667;
          };

          class "users" {
            number_per_ip = 3;
          };

          auth {
            user = "*@*";
            class = "users";
            flags = exceed_limit;
          };
          channel {
            default_split_user_count = 0;
          };
        '';

        description = ''
          Solanum IRC daemon configuration file.
          check <https://github.com/solanum-ircd/solanum/blob/main/doc/reference.conf> for all options.
        '';

        type = types.str;
      };

      enable = mkEnableOption "Solanum IRC daemon";

      motd = mkOption {
        default = null;

        description = ''
          Solanum MOTD text.

          Solanum will read its MOTD from `/etc/solanum/ircd.motd`.
          If set, the value of this option will be written to this path.
        '';

        type = types.nullOr types.lines;
      };

      openFilesLimit = mkOption {
        default = 1024;

        description = ''
          Maximum number of open files. Limits the clients and server connections.
        '';

        type = types.int;
      };

    };

  };

  ###### implementation

  config = mkIf cfg.enable (
    lib.mkMerge [
      {

        environment.etc."solanum/ircd.conf".source = configFile;

        systemd.services.solanum = {
          after = [ "network.target" ];
          description = "Solanum IRC daemon";
          reloadIfChanged = true;

          restartTriggers = [
            configFile
          ];

          serviceConfig = {
            DynamicUser = true;

            ExecReload = toString [
              (lib.getExe' pkgs.util-linux "kill")
              "-HUP"
              "$MAINPID"
            ];

            ExecStart = toString [
              (lib.getExe pkgs.solanum)
              "-foreground"
              "-logfile"
              "/dev/stdout"
              "-configfile"
              "/etc/solanum/ircd.conf"
              "-pidfile"
              "/run/solanum/ircd.pid"
            ];

            LimitNOFILE = "${toString cfg.openFilesLimit}";
            RuntimeDirectory = "solanum";
            RuntimeDirectoryMode = "0700";
            StateDiectoryMode = "0750";
            StateDirectory = "solanum";
            UMask = "0027";
            User = "solanum";
          };

          wantedBy = [ "multi-user.target" ];
        };

      }

      (mkIf (cfg.motd != null) {
        environment.etc."solanum/ircd.motd".text = cfg.motd;
      })
    ]
  );
}

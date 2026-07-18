{
  config,
  lib,
  pkgs,
  options,
  ...
}:
let
  cfg = config.services.ergochat;
in
{
  options = {
    services.ergochat = {

      enable = lib.mkEnableOption "Ergo IRC daemon";

      configFile = lib.mkOption {
        default = (pkgs.formats.yaml { }).generate "ergo.conf" cfg.settings;
        defaultText = lib.literalMD "generated config file from `settings`";

        description = ''
          Path to configuration file.
          Setting this will skip any configuration done via `settings`
        '';

        type = lib.types.path;
      };

      openFilesLimit = lib.mkOption {
        default = 1024;

        description = ''
          Maximum number of open files. Limits the clients and server connections.
        '';

        type = lib.types.int;
      };

      settings = lib.mkOption {
        default = {
          accounts = {
            authentication-enabled = true;

            multiclient = {
              allowed-by-default = true;
              always-on = "opt-out";
              auto-away = "opt-out";
              enabled = true;
            };

            registration = {
              allow-before-connect = true;
              bcrypt-cost = 4;
              email-verification.enabled = false;
              enabled = true;

              throttling = {
                duration = "10m";
                enabled = true;
                max-attempts = 30;
              };
            };
          };

          channels = {
            default-modes = "+ntC";

            registration = {
              enabled = true;
            };
          };

          datastore = {
            autoupgrade = true;
            # this points to the StateDirectory of the systemd service
            path = "/var/lib/ergo/ircd.db";
          };

          history = {
            autoreplay-on-join = 0;
            autoresize-window = "3d";
            channel-length = 2048;
            chathistory-maxmessages = 100;
            client-length = 256;
            enabled = true;

            restrictions = {
              expire-time = "1w";
              grace-period = "1h";
              query-cutoff = "none";
            };

            retention = {
              allow-individual-delete = false;
              enable-account-indexing = false;
            };

            tagmsg-storage = {
              default = false;

              whitelist = [
                "+draft/react"
                "+react"
              ];
            };

            znc-maxmessages = 2048;
          };

          limits = {
            awaylen = 390;
            channellen = 64;
            identlen = 20;
            kicklen = 390;
            nicklen = 32;
            topiclen = 390;
          };

          network = {
            name = "testnetwork";
          };

          server = {
            casemapping = "permissive";
            check-ident = false;
            enforce-utf = true;
            forward-confirm-hostnames = false;

            ip-cloaking = {
              enabled = false;
            };

            ip-limits = {
              count = false;
              throttle = false;
            };

            listeners = {
              ":6667" = { };
            };

            lookup-hostnames = false;
            max-sendq = "1M";
            name = "example.com";

            relaymsg = {
              enabled = false;
            };
          };
        };

        description = ''
          Ergo IRC daemon configuration file.
          https://raw.githubusercontent.com/ergochat/ergo/master/default.yaml
        '';

        type = (pkgs.formats.yaml { }).type;
      };

    };
  };

  config = lib.mkIf cfg.enable {

    environment.etc."ergo.yaml".source = cfg.configFile;

    # merge configured values with default values
    services.ergochat.settings = lib.mapAttrsRecursive (
      _: lib.mkDefault
    ) options.services.ergochat.settings.default;

    systemd.services.ergochat = {
      description = "Ergo IRC daemon";
      reloadTriggers = [ cfg.configFile ];

      serviceConfig = {
        DynamicUser = true;
        ExecStart = "${pkgs.ergochat}/bin/ergo run --conf /etc/ergo.yaml";
        LimitNOFILE = toString cfg.openFilesLimit;
        StateDirectory = "ergo";
        Type = "notify-reload";
      };

      wantedBy = [ "multi-user.target" ];
    };

  };

  meta.maintainers = with lib.maintainers; [
    lassulus
    tv
  ];
}

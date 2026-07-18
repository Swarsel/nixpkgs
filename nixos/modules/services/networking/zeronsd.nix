{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.zeronsd;
  settingsFormat = pkgs.formats.json { };
in
{
  options.services.zeronsd.servedNetworks = lib.mkOption {
    default = { };
    description = "ZeroTier Networks to start zeronsd instances for.";

    example = {
      "a8a2c3c10c1a68de".settings.token = "/var/lib/zeronsd/apitoken";
    };

    type = lib.types.attrsOf (
      lib.types.submodule {
        options = {
          package = lib.mkPackageOption pkgs "zeronsd" { };

          settings = lib.mkOption {
            default = { };
            description = "Settings for zeronsd";

            type = lib.types.submodule {
              options = {
                domain = lib.mkOption {
                  default = "home.arpa";
                  description = "Domain under which ZeroTier records will be available.";
                  type = lib.types.singleLineStr;
                };

                log_level = lib.mkOption {
                  default = "warn";
                  description = "Log Level.";

                  type = lib.types.enum [
                    "off"
                    "error"
                    "warn"
                    "info"
                    "debug"
                    "trace"
                  ];
                };

                token = lib.mkOption {
                  description = "Path to a file containing the API Token for ZeroTier Central.";
                  type = lib.types.path;
                };

                wildcard = lib.mkOption {
                  default = false;
                  description = "Whether to serve a wildcard record for ZeroTier Nodes.";
                  type = lib.types.bool;
                };
              };

              freeformType = settingsFormat.type;
            };
          };
        };
      }
    );
  };

  config = lib.mkIf (cfg.servedNetworks != { }) {
    assertions = [
      {
        assertion = config.services.zerotierone.enable;
        message = "zeronsd needs a configured zerotier-one";
      }
    ];

    systemd.services = lib.mapAttrs' (netname: netcfg: {
      name = "zeronsd-${netname}";

      value = {
        after = [
          "network.target"
          "zerotierone.service"
        ];

        description = "ZeroTier DNS server for Network ${netname}";

        serviceConfig =
          let
            configFile = pkgs.writeText "zeronsd.json" (builtins.toJSON netcfg.settings);
          in
          {
            AmbientCapabilities = "CAP_NET_BIND_SERVICE";
            ExecStart = "${netcfg.package}/bin/zeronsd start --config ${configFile} --config-type json ${netname}";
            Group = "zeronsd";
            Restart = "on-failure";
            RestartSec = 2;
            TimeoutStopSec = 5;
            User = "zeronsd";
          };

        wantedBy = [ "multi-user.target" ];
        wants = [ "network-online.target" ];
      };
    }) cfg.servedNetworks;

    systemd.tmpfiles.rules = [
      "a+ /var/lib/zerotier-one - - - - mask::x,u:zeronsd:x"
      "a+ /var/lib/zerotier-one/authtoken.secret - - - - mask::r,u:zeronsd:r"
    ];

    users.groups.zeronsd = { };

    users.users.zeronsd = {
      description = "Service user for running zeronsd";
      group = "zeronsd";
      isSystemUser = true;
    };
  };
}

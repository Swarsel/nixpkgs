{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.goupile;
  settingsFormat = pkgs.formats.ini { };
in
{
  options.services.goupile = {
    enable = lib.mkEnableOption "Goupile server";
    package = lib.mkPackageOption pkgs "goupile" { };

    configFile = lib.mkOption {
      description = ''
        The configuration file to be passed to goupile server.

        By default the configuration file is created from `services.goupile.settings`.
      '';

      type = lib.types.path;
    };

    enableSandbox = lib.mkOption {
      default = true;
      description = "Enable the sandbox option.";
      type = lib.types.bool;
    };

    hostName = lib.mkOption {
      default = config.networking.fqdnOrHostName;
      defaultText = lib.literalExpression "config.networking.fqdnOrHostName";
      description = "Nginx service name for goupile service.";
      type = lib.types.str;
    };

    settings = lib.mkOption {
      default = { }; # default will be lost for submodules if overriden

      description = ''
        The options for `systemd.services.goupile` in ini format.

        The configuration options available can be found here
        https://github.com/Koromix/rygel/blob/goupile/3.11.1/src/goupile/server/admin.cc#L41
      '';

      example = lib.literalExpression ''
        {
          HTTP.Port = 8888;
        }
      '';

      type = lib.types.submodule {
        options = {
          Data.RootDirectory = lib.mkOption {
            default = "/var/lib/goupile";
            description = "Goupile's data directory.";
            type = lib.types.str;
          };

          HTTP.Port = lib.mkOption {
            default = 8889;
            description = "The port goupile runs on";
            type = lib.types.port;
          };
        };

        freeformType = settingsFormat.type;
      };
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        services.nginx = {
          enable = lib.mkDefault true;

          virtualHosts.${cfg.hostName} = {
            locations."/".proxyPass = "http://127.0.0.1:${builtins.toString cfg.settings.HTTP.Port}";
          };
        };
      }
      {
        services.goupile.configFile = settingsFormat.generate "goupile.ini" cfg.settings;
      }
      {
        systemd.services.goupile = {
          after = [ "network-online.target" ];
          description = "Goupile eCRF";
          documentation = [ "https://goupile.org/en" ];

          serviceConfig = {
            CapabilityBoundingSet = [
              "CAP_SYS_PTRACE"
              "CAP_CHOWN"
              "CAP_DAC_OVERRIDE"
              "CAP_FOWNER"
              "CAP_KILL" # Required for child process management
              "CAP_NET_BIND_SERVICE"
              "CAP_SETGID"
              "CAP_SETUID"
              "CAP_SYS_CHROOT"
              "CAP_SYS_RESOURCE"
            ];

            DynamicUser = true;

            ExecStart = ''
              ${lib.getExe cfg.package} \
                ${lib.optionalString cfg.enableSandbox "--sandbox"} \
                -C ${cfg.configFile}
            '';

            LimitNOFILE = 4096;
            PrivateDevices = true;
            PrivateUsers = true;
            ProtectControlGroups = true;
            ProtectHome = true;
            ProtectKernelLogs = true;
            ProtectKernelModules = true;
            Restart = "always";
            RestartSec = 20;
            RuntimeDirectory = "goupile";
            RuntimeDirectoryPreserve = "yes";
            StateDirectory = "goupile";
            SystemCallArchitectures = "native";

            SystemCallFilter = [
              "~@privileged"
              "~@resources"
              "~@obsolete"
              "~@mount"
              "@system-service"
              "@file-system"
              "@basic-io"
              "@clock"
            ];

            TimeoutStopSec = 30;
            UMask = 0077;
            WorkingDirectory = "%S/goupile";
          };

          wantedBy = [ "multi-user.target" ];
          wants = [ "network-online.target" ];
        };
      }
    ]
  );

  meta.maintainers = lib.teams.ngi.members;
}

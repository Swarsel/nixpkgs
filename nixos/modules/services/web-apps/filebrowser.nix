{
  config,
  lib,
  pkgs,
  utils,
  ...
}:
let
  cfg = config.services.filebrowser;
  format = pkgs.formats.json { };
  inherit (lib) types;
in
{
  options = {
    services.filebrowser = {
      enable = lib.mkEnableOption "FileBrowser";
      package = lib.mkPackageOption pkgs "filebrowser" { };

      group = lib.mkOption {
        default = "filebrowser";
        description = "Group under which FileBrowser runs.";
        type = types.str;
      };

      openFirewall = lib.mkEnableOption "opening firewall ports for FileBrowser";

      settings = lib.mkOption {
        default = { };

        description = ''
          Settings for FileBrowser.
          Refer to <https://filebrowser.org/cli/filebrowser#options> for all supported values.
        '';

        type = types.submodule {
          options = {
            address = lib.mkOption {
              default = "localhost";

              description = ''
                The address to listen on.
              '';

              type = types.str;
            };

            cache-dir = lib.mkOption {
              default = "/var/cache/filebrowser";

              description = ''
                The directory where FileBrowser stores its cache.
              '';

              readOnly = true;
              type = types.path;
            };

            database = lib.mkOption {
              default = "/var/lib/filebrowser/database.db";

              description = ''
                The path to FileBrowser's Bolt database.
              '';

              type = types.path;
            };

            port = lib.mkOption {
              default = 8080;

              description = ''
                The port to listen on.
              '';

              type = types.port;
            };

            root = lib.mkOption {
              default = "/var/lib/filebrowser/data";

              description = ''
                The directory where FileBrowser stores files.
              '';

              type = types.path;
            };
          };

          freeformType = format.type;
        };
      };

      user = lib.mkOption {
        default = "filebrowser";
        description = "User account under which FileBrowser runs.";
        type = types.str;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [ cfg.settings.port ];

    systemd = {
      services.filebrowser = {
        after = [ "network.target" ];
        description = "FileBrowser";

        serviceConfig = {
          CacheDirectory = "filebrowser";
          DevicePolicy = "closed";

          ExecStart =
            let
              args = [
                (lib.getExe cfg.package)
                "--config"
                (format.generate "config.json" cfg.settings)
              ];
            in
            utils.escapeSystemdExecArgs args;

          Group = cfg.group;
          LockPersonality = true;
          MemoryDenyWriteExecute = true;
          NoNewPrivileges = true;
          PrivateDevices = true;
          ProtectControlGroups = true;
          ProtectKernelModules = true;
          ProtectKernelTunables = true;

          RestrictAddressFamilies = [
            "AF_UNIX"
            "AF_INET"
            "AF_INET6"
          ];

          RestrictNamespaces = true;
          RestrictRealtime = true;
          RestrictSUIDSGID = true;
          StateDirectory = "filebrowser";
          UMask = "0077";
          User = cfg.user;
          WorkingDirectory = cfg.settings.root;
        };

        wantedBy = [ "multi-user.target" ];
      };

      tmpfiles.settings.filebrowser = {
        "${cfg.settings.cache-dir}".d = {
          inherit (cfg) user group;
          mode = "0700";
        };

        "${cfg.settings.root}".d = {
          inherit (cfg) user group;
          mode = "0700";
        };

        "${dirOf cfg.settings.database}".d = {
          inherit (cfg) user group;
          mode = "0700";
        };
      };
    };

    users.groups = lib.mkIf (cfg.group == "filebrowser") {
      filebrowser = { };
    };

    users.users = lib.mkIf (cfg.user == "filebrowser") {
      filebrowser = {
        inherit (cfg) group;
        isSystemUser = true;
      };
    };
  };

  meta.maintainers = [
    lib.maintainers.lukaswrz
  ];
}

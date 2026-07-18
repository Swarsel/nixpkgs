{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.archisteamfarm;

  format = pkgs.formats.json { };

  configFile = format.generate "ASF.json" (
    cfg.settings
    // {
      Headless = true;
      # we disable it because ASF cannot update itself anyways
      # and nixos takes care of restarting the service
      # is in theory not needed as this is already the default for default builds
      UpdateChannel = 0;
    }
    // lib.optionalAttrs (cfg.ipcPasswordFile != null) {
      IPCPassword = "#ipcPassword#";
    }
  );

  ipc-config = format.generate "IPC.config" cfg.ipcSettings;

  mkBot =
    n: c:
    format.generate "${n}.json" (
      c.settings
      // {
        Enabled = c.enabled;
        SteamLogin = if c.username == "" then n else c.username;
      }
      // lib.optionalAttrs (c.passwordFile != null) {
        # sets the password format to file (https://github.com/JustArchiNET/ArchiSteamFarm/wiki/Security#file)
        PasswordFormat = 4;
        SteamPassword = c.passwordFile;
      }
    );
in
{
  options.services.archisteamfarm = {
    enable = lib.mkOption {
      default = false;

      description = ''
        If enabled, starts the ArchisSteamFarm service.
        For configuring the SteamGuard token you will need to use the web-ui, which is enabled by default over on 127.0.0.1:1242.
        You cannot configure ASF in any way outside of nix, since all the config files get wiped on restart and replaced with the programnatically set ones by nix.
      '';

      type = lib.types.bool;
    };

    package = lib.mkPackageOption pkgs "archisteamfarm" {
      extraDescription = ''
        ::: {.warning}
        Should always be the latest version, for security reasons,
        since this module uses very new features and to not get out of sync with the Steam API.
        :::
      '';
    };

    bots = lib.mkOption {
      default = { };

      description = ''
        Bots name and configuration.
      '';

      example = {
        exampleBot = {
          passwordFile = "/var/lib/archisteamfarm/secrets/password";

          settings = {
            SteamParentalCode = "1234";
          };

          username = "alice";
        };
      };

      type = lib.types.attrsOf (
        lib.types.submodule {
          options = {
            enabled = lib.mkOption {
              default = true;
              description = "Whether to enable the bot on startup.";
              type = lib.types.bool;
            };

            passwordFile = lib.mkOption {
              default = null;

              description = ''
                Path to a file containing the password. The file must be readable by the `archisteamfarm` user/group.
                Omit or set to null to provide the password a different way, such as through the web-ui.
              '';

              type = with lib.types; nullOr path;
            };

            settings = lib.mkOption {
              default = { };

              description = ''
                Additional settings that are documented [here](https://github.com/JustArchiNET/ArchiSteamFarm/wiki/Configuration#bot-config).
              '';

              type = lib.types.attrs;
            };

            username = lib.mkOption {
              default = "";
              description = "Name of the user to log in. Default is attribute name.";
              type = lib.types.str;
            };
          };
        }
      );
    };

    dataDir = lib.mkOption {
      default = "/var/lib/archisteamfarm";

      description = ''
        The ASF home directory used to store all data.
        If left as the default value this directory will automatically be created before the ASF server starts, otherwise the sysadmin is responsible for ensuring the directory exists with appropriate ownership and permissions.'';

      type = lib.types.path;
    };

    ipcPasswordFile = lib.mkOption {
      default = null;
      description = "Path to a file containing the password. The file must be readable by the `archisteamfarm` user/group.";
      type = with lib.types; nullOr path;
    };

    ipcSettings = lib.mkOption {
      default = { };

      description = ''
        Settings to write to IPC.config.
        All options can be found [here](https://github.com/JustArchiNET/ArchiSteamFarm/wiki/IPC#custom-configuration).
      '';

      example = {
        Kestrel = {
          Endpoints = {
            HTTP = {
              Url = "http://*:1242";
            };
          };
        };
      };

      type = format.type;
    };

    settings = lib.mkOption {
      default = { };

      description = ''
        The ASF.json file, all the options are documented [here](https://github.com/JustArchiNET/ArchiSteamFarm/wiki/Configuration#global-config).
        Do note that `AutoRestart`  and `UpdateChannel` is always to `false` respectively `0` because NixOS takes care of updating everything.
        `Headless` is also always set to `true` because there is no way to provide inputs via a systemd service.
        You should try to keep ASF up to date since upstream does not provide support for anything but the latest version and you're exposing yourself to all kinds of issues - as is outlined [here](https://github.com/JustArchiNET/ArchiSteamFarm/wiki/Configuration#updateperiod).
      '';

      example = {
        Statistics = false;
      };

      type = format.type;
    };

    web-ui = lib.mkOption {
      default = {
        enable = true;
      };

      description = "The Web-UI hosted on 127.0.0.1:1242.";

      example = {
        enable = false;
      };

      type = lib.types.submodule {
        options = {
          enable = lib.mkEnableOption "" // {
            description = "Whether to start the web-ui. This is the preferred way of configuring things such as the steam guard token.";
          };

          package = lib.mkPackageOption pkgs [ "archisteamfarm" "ui" ] {
            extraDescription = ''
              ::: {.note}
              Contents must be in lib/dist
              :::
            '';
          };
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services = {
      archisteamfarm = {
        after = [ "network.target" ];
        description = "Archis-Steam-Farm Service";

        preStart =
          let
            createBotsScript =
              pkgs.runCommand "ASF-bots"
                {
                  preferLocalBuild = true;
                }
                ''
                  mkdir -p $out
                  # clean potential removed bots
                  rm -rf $out/*.json
                  for i in ${
                    lib.concatStringsSep " " (map (x: "${lib.getName x},${x}") (lib.mapAttrsToList mkBot cfg.bots))
                  }; do IFS=",";
                    set -- $i
                    ln -fs $2 $out/$1
                  done
                '';
            replaceSecretBin = "${pkgs.replace-secret}/bin/replace-secret";
          in
          ''
            mkdir -p config

            cp --no-preserve=mode ${configFile} config/ASF.json

            ${lib.optionalString (cfg.ipcPasswordFile != null) ''
              ${replaceSecretBin} '#ipcPassword#' '${cfg.ipcPasswordFile}' config/ASF.json
            ''}

            ${lib.optionalString (cfg.ipcSettings != { }) ''
              ln -fs ${ipc-config} config/IPC.config
            ''}

            ${lib.optionalString (cfg.bots != { }) ''
              ln -fs ${createBotsScript}/* config/
            ''}

            rm -f www
            ${lib.optionalString cfg.web-ui.enable ''
              ln -s ${cfg.web-ui.package}/ www
            ''}
          '';

        serviceConfig = lib.mkMerge [
          (lib.mkIf (lib.hasPrefix "/var/lib/" cfg.dataDir) {
            StateDirectory = lib.last (lib.splitString "/" cfg.dataDir);
            StateDirectoryMode = "700";
          })
          {
            # copied from the default systemd service at
            # https://github.com/JustArchiNET/ArchiSteamFarm/blob/main/ArchiSteamFarm/overlay/variant-base/linux/ArchiSteamFarm%40.service
            CapabilityBoundingSet = "";
            DevicePolicy = "closed";
            ExecStart = "${lib.getExe cfg.package} --no-restart --service --system-required --path ${cfg.dataDir}";
            Group = "archisteamfarm";
            LockPersonality = true;
            NoNewPrivileges = true;
            PrivateDevices = true;
            PrivateIPC = true;
            PrivateMounts = true;
            PrivateTmp = true; # instead of rw /tmp
            PrivateUsers = true;
            ProcSubset = "pid";
            ProtectClock = true;
            ProtectControlGroups = true;
            ProtectHome = true;
            ProtectHostname = true;
            ProtectKernelLogs = true;
            ProtectKernelModules = true;
            ProtectKernelTunables = true;
            ProtectProc = "invisible";
            ProtectSystem = "strict";
            RemoveIPC = true;
            Restart = "always";
            RestrictAddressFamilies = "AF_INET AF_INET6 AF_NETLINK AF_UNIX";
            RestrictNamespaces = true;
            RestrictRealtime = true;
            RestrictSUIDSGID = true;
            SecureBits = "noroot-locked";
            SystemCallArchitectures = "native";

            SystemCallFilter = [
              "@system-service"
              "~@privileged"
              "mincore"
            ];

            Type = "simple";
            UMask = "0077";
            User = "archisteamfarm";
            WorkingDirectory = cfg.dataDir;
          }
        ];

        wantedBy = [ "multi-user.target" ];
      };
    };

    users = {
      groups.archisteamfarm = { };

      users.archisteamfarm = {
        description = "Archis-Steam-Farm service user";
        group = "archisteamfarm";
        home = cfg.dataDir;
        isSystemUser = true;
      };
    };
  };

  meta = {
    buildDocsInSandbox = false;
    maintainers = with lib.maintainers; [ SuperSandro2000 ];
  };
}

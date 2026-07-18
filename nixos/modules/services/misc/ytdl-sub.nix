{
  config,
  lib,
  pkgs,
  utils,
  ...
}:

let
  cfg = config.services.ytdl-sub;

  settingsFormat = pkgs.formats.yaml { };
in

{
  options.services.ytdl-sub = {
    package = lib.mkPackageOption pkgs "ytdl-sub" { };

    group = lib.mkOption {
      default = "ytdl-sub";
      description = "Group under which ytdl-sub runs.";
      type = lib.types.str;
    };

    instances = lib.mkOption {
      default = { };
      description = "Configuration for ytdl-sub instances.";

      type = lib.types.attrsOf (
        lib.types.submodule (
          { name, ... }:
          {
            options = {
              config = lib.mkOption {
                default = { };
                description = "Configuration for ytdl-sub. See <https://ytdl-sub.readthedocs.io/en/latest/config_reference/config_yaml.html> for more information.";

                example = {
                  presets."YouTube Playlist" = {
                    download = "{subscription_value}";

                    output_options = {
                      file_name = "{channel}/{playlist_title}/{playlist_index_padded}_{title}.{ext}";
                      maintain_download_archive = true;
                      output_directory = "YouTube";
                    };
                  };
                };

                type = settingsFormat.type;
              };

              enable = lib.mkEnableOption "ytdl-sub instance";

              readWritePaths = lib.mkOption {
                default = [ ];

                description = ''
                  List of paths that ytdl-sub can write to.
                '';

                type = lib.types.listOf lib.types.path;
              };

              schedule = lib.mkOption {
                default = null;
                description = "How often to run ytdl-sub. See {manpage}`systemd.time(7)` for the format.";
                example = "0/6:0";
                type = lib.types.nullOr lib.types.str;
              };

              subscriptions = lib.mkOption {
                default = { };
                description = "Subscriptions for ytdl-sub. See <https://ytdl-sub.readthedocs.io/en/latest/config_reference/subscription_yaml.html> for more information.";

                example = {
                  "YouTube Playlist" = {
                    "Some Playlist" = "https://www.youtube.com/playlist?list=...";
                  };
                };

                type = settingsFormat.type;
              };
            };

            config = {
              config.configuration.working_directory = "/run/ytdl-sub/${utils.escapeSystemdPath name}";
            };
          }
        )
      );
    };

    user = lib.mkOption {
      default = "ytdl-sub";
      description = "User account under which ytdl-sub runs.";
      type = lib.types.str;
    };
  };

  config = lib.mkIf (cfg.instances != { }) {
    systemd.services =
      let
        mkService =
          name: instance:
          let
            configFile = settingsFormat.generate "config.yaml" instance.config;
            subscriptionsFile = settingsFormat.generate "subscriptions.yaml" instance.subscriptions;
          in
          lib.nameValuePair "ytdl-sub-${utils.escapeSystemdPath name}" {
            inherit (instance) enable;
            after = [ "network-online.target" ];

            serviceConfig = {
              # Hardening
              CapabilityBoundingSet = [ "" ];
              DeviceAllow = [ "" ];
              ExecStart = "${lib.getExe cfg.package} --config ${configFile} sub ${subscriptionsFile}";
              Group = cfg.group;
              LockPersonality = true;
              PrivateDevices = true;
              PrivateTmp = true;
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
              ReadWritePaths = instance.readWritePaths;

              RestrictAddressFamilies = [
                "AF_INET"
                "AF_INET6"
                "AF_UNIX"
              ];

              RestrictNamespaces = true;
              RestrictRealtime = true;
              RestrictSUIDSGID = true;
              RuntimeDirectory = "ytdl-sub/${utils.escapeSystemdPath name}";
              StateDirectory = "ytdl-sub/${utils.escapeSystemdPath name}";
              SystemCallArchitectures = "native";
              User = cfg.user;
              WorkingDirectory = "/var/lib/ytdl-sub/${utils.escapeSystemdPath name}";
            };

            startAt = lib.optional (instance.schedule != null) instance.schedule;
            wants = [ "network-online.target" ];
          };
      in
      lib.mapAttrs' mkService cfg.instances;

    users.groups = lib.mkIf (cfg.group == "ytdl-sub") { ytdl-sub = { }; };

    users.users = lib.mkIf (cfg.user == "ytdl-sub") {
      ytdl-sub = {
        group = cfg.group;
        isSystemUser = true;
      };
    };
  };

  meta.maintainers = with lib.maintainers; [ defelo ];
}

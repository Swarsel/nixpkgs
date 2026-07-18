{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.prometheus.alertmanager-ntfy;

  settingsFormat = pkgs.formats.yaml { };
  settingsFile = settingsFormat.generate "settings.yml" cfg.settings;

  configsArg = lib.concatStringsSep "," (
    [ settingsFile ] ++ lib.imap0 (i: _: "%d/config-${toString i}.yml") cfg.extraConfigFiles
  );
in

{
  options.services.prometheus.alertmanager-ntfy = {
    enable = lib.mkEnableOption "alertmanager-ntfy";
    package = lib.mkPackageOption pkgs "alertmanager-ntfy" { };

    extraConfigFiles = lib.mkOption {
      default = [ ];

      description = ''
        Config files to merge into the settings defined in [](#opt-services.prometheus.alertmanager-ntfy.settings).
        This is useful to avoid putting secrets into the Nix store.
        See <https://github.com/alexbakker/alertmanager-ntfy> for more information.
      '';

      example = [ "/run/secrets/alertmanager-ntfy.yml" ];
      type = lib.types.listOf lib.types.path;
    };

    settings = lib.mkOption {
      default = { };

      description = ''
        Configuration of alertmanager-ntfy.
        See <https://github.com/alexbakker/alertmanager-ntfy> for more information.
      '';

      type = lib.types.submodule {
        options = {
          http.addr = lib.mkOption {
            default = "127.0.0.1:8000";
            description = "The address to listen on.";
            example = ":8000";
            type = lib.types.str;
          };

          ntfy = {
            baseurl = lib.mkOption {
              description = "The base URL of the ntfy.sh instance.";
              example = "https://ntfy.sh";
              type = lib.types.str;
            };

            notification = {
              priority = lib.mkOption {
                default = ''status == "firing" ? "high" : "default"'';

                description = ''
                  The ntfy.sh message priority (see <https://docs.ntfy.sh/publish/#message-priority> for more information).
                  Can either be a hardcoded string or a gval expression that evaluates to a string.
                '';

                type = lib.types.str;
              };

              tags = lib.mkOption {
                default = [
                  {
                    condition = ''status == "resolved"'';
                    tag = "green_circle";
                  }
                  {
                    condition = ''status == "firing"'';
                    tag = "red_circle";
                  }
                ];

                description = ''
                  Tags to add to ntfy.sh messages.
                  See <https://docs.ntfy.sh/publish/#tags-emojis> for more information.
                '';

                type = lib.types.listOf (
                  lib.types.submodule {
                    options = {
                      condition = lib.mkOption {
                        default = null;

                        description = ''
                          The condition under which this tag should be added.
                          Tags with no condition are always included.
                        '';

                        example = ''status == "firing"'';
                        type = lib.types.nullOr lib.types.str;
                      };

                      tag = lib.mkOption {
                        description = ''
                          The tag to add.
                          See <https://docs.ntfy.sh/emojis> for a list of all supported emojis.
                        '';

                        example = "rotating_light";
                        type = lib.types.str;
                      };
                    };
                  }
                );
              };

              templates = {
                description = lib.mkOption {
                  default = ''
                    {{ index .Annotations "description" }}
                  '';

                  description = "The ntfy.sh message description template.";
                  type = lib.types.str;
                };

                title = lib.mkOption {
                  default = ''
                    {{ if eq .Status "resolved" }}Resolved: {{ end }}{{ index .Annotations "summary" }}
                  '';

                  description = "The ntfy.sh message title template.";
                  type = lib.types.str;
                };
              };

              topic = lib.mkOption {
                description = ''
                  __Note:__ when using ntfy.sh and other public instances
                  it is recommended to set this option to an empty string and set the actual topic via
                  [](#opt-services.prometheus.alertmanager-ntfy.extraConfigFiles) since
                  the `topic` in `ntfy.sh` is essentially a password.

                  The topic to which alerts should be published.
                  Can either be a hardcoded string or a gval expression that evaluates to a string.
                '';

                example = "alertmanager";
                type = lib.types.str;
              };
            };
          };
        };

        freeformType = settingsFormat.type;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.alertmanager-ntfy = {
      after = [ "network-online.target" ];

      serviceConfig = {
        # Hardening
        AmbientCapabilities = "";
        CapabilityBoundingSet = [ "" ];
        DevicePolicy = "closed";
        DynamicUser = true;
        ExecStart = "${lib.getExe cfg.package} --configs ${configsArg}";
        Group = "alertmanager-ntfy";
        LoadCredential = lib.imap0 (i: path: "config-${toString i}.yml:${path}") cfg.extraConfigFiles;
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        NoNewPrivileges = true;
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
        RemoveIPC = true;
        Restart = "always";
        RestartSec = 5;
        RestrictAddressFamilies = [ "AF_INET AF_INET6" ];
        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        SystemCallArchitectures = "native";

        SystemCallFilter = [
          "@system-service"
          "~@privileged"
          "~@resources"
        ];

        UMask = "0077";
        User = "alertmanager-ntfy";
      };

      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
    };
  };

  meta.maintainers = with lib.maintainers; [ defelo ];
}

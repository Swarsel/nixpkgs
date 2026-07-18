{
  config,
  lib,
  pkgs,
  utils,
  ...
}:
let
  cfg = config.services.tuliprox;
  settingsFormat = pkgs.formats.yaml { };
  systemSettingsYaml = settingsFormat.generate "config.yml" cfg.systemSettings;
  sourceSettingsYaml = settingsFormat.generate "source.yml" cfg.sourceSettings;
  apiProxySettingsYaml = settingsFormat.generate "api-proxy.yml" cfg.apiProxySettings;
  mappingSettingsYaml = settingsFormat.generate "mapping.yml" cfg.mappingSettings;
in
{
  options.services.tuliprox = {
    enable = lib.mkEnableOption "Tuliprox IPTV playlist processor & proxy";
    package = lib.mkPackageOption pkgs "tuliprox" { };

    apiProxySettings = lib.mkOption {
      description = ''
        Users and proxy configuration

        Refer to the [Tuliprox documentation] for available attributes

        [Tuliprox documentation]: https://github.com/euzu/tuliprox?tab=readme-ov-file#3-api-proxy-config
      '';

      example = {
        server = [
          {
            host = "192.169.1.9";
            message = "Welcome to tuliprox";
            name = "default";
            port = 8901;
            protocol = "http";
            timezone = "Europe/Paris";
          }
          {
            host = "tuliprox.mydomain.tv";
            message = "Welcome to tuliprox";
            name = "external";
            port = 443;
            protocol = "https";
            timezone = "Europe/Paris";
          }
        ];

        user = [
          {
            credentials = [
              {
                exp_date = 1672705545;
                max_connections = 1;
                password = "secret1";
                proxy = "reverse";
                server = "default";
                status = "Active";
                token = "token1";
                username = "test1";
              }
            ];

            target = "xc_m3u";
          }
        ];
      };

      type = settingsFormat.type;
    };

    extraArgs = lib.mkOption {
      default = [ ];

      description = ''
        Additional command-line arguments for the systemd service.

        Refer to the [Tuliprox documentation] for available arguments.

        [Tuliprox documentation]: https://github.com/euzu/tuliprox?tab=readme-ov-file#command-line-arguments
      '';

      type = lib.types.listOf lib.types.str;
    };

    mappingSettings = lib.mkOption {
      description = ''
        Templates configuration

        Refer to the [Tuliprox documentation] for available attributes

        [Tuliprox documentation]: https://github.com/euzu/tuliprox?tab=readme-ov-file#2-mappingyml
      '';

      example = {
        mappings = {
          mapping = [
            {
              id = "iptv-org";

              mapper = [
                {
                  filter = "!bbc!";

                  script = ''
                    @Group = "BBC"
                  '';
                }
                {
                  filter = "!documentary!";

                  script = ''
                    @Group = "Documentary"
                  '';
                }
                {
                  filter = "!entertainment!";

                  script = ''
                    @Group = "Entertainment"
                  '';
                }
                {
                  filter = "!pluto_tv!";

                  script = ''
                    @Group = "Pluto TV"
                  '';
                }
                {
                  filter = "!business!";

                  script = ''
                    @Group = "News"
                  '';
                }
                {
                  filter = "Input ~ \"iptv-org\"";

                  script = ''
                    @Caption = concat(@Caption, " (iptv-org)")
                  '';
                }
              ];

              match_as_ascii = true;
            }
          ];

          templates = [
            {
              name = "bbc";
              value = "Title ~ \"^BBC\"";
            }
            {
              name = "documentary";
              value = "(Group ~ \"(Documentary|Outdoor)\")";
            }
            {
              name = "entertainment";
              value = "Group ~ \"Entertainment\"";
            }
            {
              name = "pluto_tv";
              value = "(Caption ~ \"Pluto TV\") AND NOT(Caption ~ \"Sports\")";
            }
            {
              name = "business";
              value = "Group ~ \"Business\"";
            }
          ];
        };
      };

      type = settingsFormat.type;
    };

    sourceSettings = lib.mkOption {
      description = ''
        Source definitions

        Refer to the [Tuliprox documentation] for available attributes

        [Tuliprox documentation]: https://github.com/euzu/tuliprox?tab=readme-ov-file#2-sourceyml
      '';

      example = {
        sources = [
          {
            inputs = [
              {
                name = "iptv-org";
                type = "m3u";
                url = "https://iptv-org.github.io/iptv/countries/uk.m3u";
              }
            ];

            targets = [
              {
                options = {
                  ignore_logo = false;
                  share_live_streams = true;
                };

                filter = "!final_channel_lineup!";

                mapping = [
                  "iptv-org"
                ];

                name = "iptv-org";

                output = [
                  {
                    type = "xtream";
                  }
                  {
                    filename = "iptv.m3u";
                    type = "m3u";
                  }
                  {
                    device = "hdhr1";
                    type = "hdhomerun";
                    username = "local";
                  }
                ];
              }
            ];
          }
        ];

        templates = [
          {
            name = "not_red_button";
            value = "NOT (Title ~ \"(?i).*red button.*\")";
          }
          {
            name = "not_low_resolution";
            value = "NOT (Title ~ \"(?i).*(360p|240p).*\")";
          }
          {
            name = "all_channels";
            value = "Title ~ \".*\"";
          }
          {
            name = "final_channel_lineup";
            value = "!all_channels! AND !not_red_button! AND !not_low_resolution!";
          }
        ];
      };

      type = settingsFormat.type;
    };

    systemSettings = lib.mkOption {
      description = ''
        Main config file

        Refer to the [Tuliprox documentation] for available attributes

        [Tuliprox documentation]: https://github.com/euzu/tuliprox?tab=readme-ov-file#1-configyml
      '';

      example = {
        api = {
          host = "0.0.0.0";
          port = 8901;
        };
      };

      type = settingsFormat.type;
    };
  };

  config = lib.mkIf cfg.enable {
    services.tuliprox.apiProxySettings = {
      server = lib.mkDefault [
        {
          host = cfg.systemSettings.api.host;
          message = "Welcome to tuliprox";
          name = "default";
          port = cfg.systemSettings.api.port;
          protocol = "http";
          timezone = if config.time.timeZone != null then config.time.timeZone else "Etc/UTC";
        }
      ];

      user = lib.mkDefault [ ];
    };

    services.tuliprox.mappingSettings.mappings.mapping = lib.mkDefault [ ];
    services.tuliprox.sourceSettings.sources = lib.mkDefault [ ];

    services.tuliprox.systemSettings = {
      api = {
        host = lib.mkDefault "127.0.0.1";
        port = lib.mkDefault 8901;
        web_root = lib.mkDefault "${cfg.package}/web";
      };

      backup_dir = lib.mkDefault "\${env:STATE_DIRECTORY}/backup";
      custom_stream_response_path = lib.mkDefault "${cfg.package}/resources";
      working_dir = lib.mkDefault "\${env:STATE_DIRECTORY}/data";
    };

    systemd.services.tuliprox = {
      description = "Tuliprox server";

      serviceConfig = {
        CapabilityBoundingSet = "";
        DynamicUser = true;

        ExecStart = utils.escapeSystemdExecArgs (
          [
            (lib.getExe cfg.package)
            "--server"
            "--config"
            systemSettingsYaml
            "--source"
            sourceSettingsYaml
            "--api-proxy"
            apiProxySettingsYaml
            "--mapping"
            mappingSettingsYaml
          ]
          ++ cfg.extraArgs
        );

        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        PrivateDevices = true;
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
        Restart = "always";

        RestrictAddressFamilies = [
          "AF_UNIX"
          "AF_INET"
          "AF_INET6"
        ];

        RestrictNamespaces = true;
        RestrictRealtime = true;
        StateDirectory = "tuliprox";
        SystemCallArchitectures = "native";

        SystemCallFilter = [
          "@system-service"
          "~@privileged"
          "~@resources"
        ];

        UMask = "0066";
      };

      wantedBy = [ "multi-user.target" ];
    };
  };

  meta.maintainers = with lib.maintainers; [ nyanloutre ];
}

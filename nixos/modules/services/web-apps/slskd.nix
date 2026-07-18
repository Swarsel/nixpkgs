{
  config,
  lib,
  pkgs,
  ...
}:

let
  settingsFormat = pkgs.formats.yaml { };
  defaultUser = "slskd";
in
{
  options.services.slskd =
    with lib;
    with types;
    {
      enable = mkEnableOption "slskd";
      package = mkPackageOption pkgs "slskd" { };

      domain = mkOption {
        description = ''
          If non-null, enables an nginx reverse proxy virtual host at this FQDN,
          at the path configurated with `services.slskd.web.url_base`.
        '';

        example = "slskd.example.com";
        type = types.nullOr types.str;
      };

      environmentFile = mkOption {
        description = ''
          Path to the environment file sourced on startup.
          It must at least contain the variables `SLSKD_SLSK_USERNAME` and `SLSKD_SLSK_PASSWORD`.
          Web interface credentials should also be set here in `SLSKD_USERNAME` and `SLSKD_PASSWORD`.
          Other, optional credentials like SOCKS5 with `SLSKD_SLSK_PROXY_USERNAME` and `SLSKD_SLSK_PROXY_PASSWORD`
          should all reside here instead of in the world-readable nix store.
          Variables are documented at <https://github.com/slskd/slskd/blob/master/docs/config.md>
        '';

        type = path;
      };

      group = mkOption {
        default = defaultUser;
        description = "Group under which slskd runs.";
        type = types.str;
      };

      nginx = mkOption {
        default = { };

        description = ''
          This option customizes the nginx virtual host set up for slskd.
        '';

        example = lib.literalExpression ''
          {
            enableACME = true;
            forceSSL = true;
          }
        '';

        type = types.submodule (import ../web-servers/nginx/vhost-options.nix { inherit config lib; });
      };

      openFirewall = mkOption {
        default = false;
        description = "Whether to open the firewall for the soulseek network listen port (not the web interface port).";
        type = bool;
      };

      settings = mkOption {
        default = { };

        description = ''
          Application configuration for slskd. See
          [documentation](https://github.com/slskd/slskd/blob/master/docs/config.md).
        '';

        type = submodule {
          options = {
            directories = {
              downloads = mkOption {
                default = null;
                defaultText = "/var/lib/slskd/downloads";
                description = "Directory where downloaded files are stored.";
                type = nullOr path;
              };

              incomplete = mkOption {
                default = null;
                defaultText = "/var/lib/slskd/incomplete";
                description = "Directory where incomplete downloading files are stored.";
                type = nullOr path;
              };
            };

            filters.search.request = mkOption {
              description = "Incoming search requests which match this filter are ignored.";
              example = lib.literalExpression ''[ "^.{1,2}$" ]'';
              type = listOf str;
            };

            flags = {
              force_share_scan = mkOption {
                description = "Force a rescan of shares on every startup.";
                type = bool;
              };

              no_version_check = mkOption {
                default = true;
                description = "Don't perform a version check on startup.";
                type = bool;
                visible = false;
              };
            };

            global = {
              download = {
                slots = mkOption {
                  description = "Limit of the number of concurrent download slots.";
                  type = ints.unsigned;
                };

                speed_limit = mkOption {
                  description = "Total upload download limit";
                  type = ints.unsigned;
                };
              };

              # TODO speed units
              upload = {
                slots = mkOption {
                  description = "Limit of the number of concurrent upload slots.";
                  type = ints.unsigned;
                };

                speed_limit = mkOption {
                  description = "Total upload speed limit.";
                  type = ints.unsigned;
                };
              };
            };

            logger = {
              # Disable by default, journald already retains as needed
              disk = mkOption {
                default = false;
                description = "Whether to log to the application directory.";
                type = bool;
                visible = false;
              };
            };

            remote_file_management = mkEnableOption "modification of share contents through the web ui";

            retention = {
              files = {
                complete = mkOption {
                  defaultText = "(indefinite)";
                  description = "Lifespan of completely downloaded files in minutes.";
                  example = 20160;
                  type = ints.unsigned;
                };

                incomplete = mkOption {
                  defaultText = "(indefinite)";
                  description = "Lifespan of incomplete downloading files in minutes.";
                  type = ints.unsigned;
                };
              };

              transfers = {
                download = {
                  cancelled = mkOption {
                    defaultText = "(indefinite)";
                    description = "Lifespan of cancelled download tasks.";
                    type = ints.unsigned;
                  };

                  errored = mkOption {
                    defaultText = "(indefinite)";
                    description = "Lifespan of errored download tasks.";
                    type = ints.unsigned;
                  };

                  succeeded = mkOption {
                    defaultText = "(indefinite)";
                    description = "Lifespan of succeeded download tasks.";
                    type = ints.unsigned;
                  };
                };

                upload = {
                  cancelled = mkOption {
                    defaultText = "(indefinite)";
                    description = "Lifespan of cancelled upload tasks.";
                    type = ints.unsigned;
                  };

                  errored = mkOption {
                    defaultText = "(indefinite)";
                    description = "Lifespan of errored upload tasks.";
                    type = ints.unsigned;
                  };

                  succeeded = mkOption {
                    defaultText = "(indefinite)";
                    description = "Lifespan of succeeded upload tasks.";
                    type = ints.unsigned;
                  };
                };
              };
            };

            rooms = mkOption {
              description = "Chat rooms to join on startup.";
              type = listOf str;
            };

            shares = {
              directories = mkOption {
                description = ''
                  Paths to shared directories. See
                  [documentation](https://github.com/slskd/slskd/blob/master/docs/config.md#directories)
                  for advanced usage.
                '';

                example = lib.literalExpression ''[ "/home/John/Music" "!/home/John/Music/Recordings" "[Music Drive]/mnt" ]'';
                type = listOf str;
              };

              filters = mkOption {
                description = "Regular expressions of files to exclude from sharing.";
                example = lib.literalExpression ''[ "\.ini$" "Thumbs.db$" "\.DS_Store$" ]'';
                type = listOf str;
              };
            };

            soulseek = {
              description = mkOption {
                defaultText = "A slskd user. https://github.com/slskd/slskd";
                description = "The user description for the Soulseek network.";
                type = str;
              };

              listen_port = mkOption {
                default = 50300;
                description = "The port on which to listen for incoming connections.";
                type = port;
              };
            };

            web = {
              # Users should use a reverse proxy instead for https
              https.disabled = mkOption {
                default = true;
                description = "Disable the built-in HTTPS server";
                type = bool;
              };

              port = mkOption {
                default = 5030;
                description = "The HTTP listen port.";
                type = port;
              };

              url_base = mkOption {
                default = "/";
                description = "The base path in the url for web requests.";
                type = path;
              };
            };
          };

          freeformType = settingsFormat.type;
        };
      };

      user = mkOption {
        default = defaultUser;
        description = "User account under which slskd runs.";
        type = types.str;
      };
    };

  config =
    let
      cfg = config.services.slskd;

      confWithoutNullValues = (
        lib.filterAttrsRecursive (
          key: value: (builtins.tryEval value).success && value != null
        ) cfg.settings
      );

      configurationYaml = settingsFormat.generate "slskd.yml" confWithoutNullValues;

    in
    lib.mkIf cfg.enable {

      networking.firewall.allowedTCPPorts = lib.optional cfg.openFirewall cfg.settings.soulseek.listen_port;

      services.nginx = lib.mkIf (cfg.domain != null) {
        enable = lib.mkDefault true;

        virtualHosts."${cfg.domain}" = lib.mkMerge [
          cfg.nginx
          {
            locations."${cfg.settings.web.url_base}" = {
              proxyPass = "http://127.0.0.1:${toString cfg.settings.web.port}";
              proxyWebsockets = true;
            };
          }
        ];
      };

      # Force off, configuration file is in nix store and is immutable
      services.slskd.settings.remote_configuration = lib.mkForce false;

      systemd.services.slskd = {
        after = [ "network.target" ];
        description = "A modern client-server application for the Soulseek file sharing network";

        serviceConfig = {
          Environment = [ "DOTNET_USE_POLLING_FILE_WATCHER=1" ];
          EnvironmentFile = lib.mkIf (cfg.environmentFile != null) cfg.environmentFile;
          ExecStart = "${cfg.package}/bin/slskd --app-dir /var/lib/slskd --config ${configurationYaml}";
          Group = cfg.group;
          LockPersonality = true;
          NoNewPrivileges = true;
          PrivateDevices = true;
          PrivateMounts = true;
          PrivateTmp = true;
          PrivateUsers = true;
          ProtectClock = true;
          ProtectControlGroups = true;
          ProtectHome = true;
          ProtectHostname = true;
          ProtectKernelLogs = true;
          ProtectKernelModules = true;
          ProtectKernelTunables = true;
          ProtectProc = "invisible";
          ProtectSystem = "strict";

          ReadOnlyPaths = map (
            d: builtins.elemAt (builtins.split "[^/]*(/.+)" d) 1
          ) cfg.settings.shares.directories;

          ReadWritePaths =
            (lib.optional (cfg.settings.directories.incomplete != null) cfg.settings.directories.incomplete)
            ++ (lib.optional (cfg.settings.directories.downloads != null) cfg.settings.directories.downloads);

          RemoveIPC = true;
          Restart = "on-failure";
          RestrictNamespaces = true;
          RestrictSUIDSGID = true;
          StateDirectory = "slskd"; # Creates /var/lib/slskd and manages permissions
          Type = "simple";
          User = cfg.user;
        };

        wantedBy = [ "multi-user.target" ];
      };

      users.groups = lib.optionalAttrs (cfg.group == defaultUser) {
        "${defaultUser}" = { };
      };

      users.users = lib.optionalAttrs (cfg.user == defaultUser) {
        "${defaultUser}" = {
          group = cfg.group;
          isSystemUser = true;
        };
      };
    };

  meta = {
    maintainers = with lib.maintainers; [
      ppom
      melvyn2
    ];
  };
}

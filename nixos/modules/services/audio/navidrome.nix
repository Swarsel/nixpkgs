{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib)
    literalExpression
    mkDefault
    mkEnableOption
    mkPackageOption
    mkOption
    maintainers
    ;
  inherit (lib.types)
    addCheck
    bool
    listOf
    package
    port
    str
    submodule
    ;
  cfg = config.services.navidrome;
  settingsFormat = pkgs.formats.json { };
in
{
  options = {
    services.navidrome = {

      enable = mkEnableOption "Navidrome music server";
      package = mkPackageOption pkgs "navidrome" { };

      environmentFile = mkOption {
        default = null;
        description = "Environment file, used to set any secret ND_* environment variables.";
        type = lib.types.nullOr lib.types.path;
      };

      finalPackage = mkOption {
        default = cfg.package.override {
          inherit (cfg) plugins;
        };

        defaultText = literalExpression ''
          config.services.navidrome.package.override {
            inherit (config.services.navidrome) plugins;
          }
        '';

        description = "The final navidrome package including all selected plugins.";
        readOnly = true;
        type = package;
      };

      group = mkOption {
        default = "navidrome";
        description = "Group under which Navidrome runs.";
        type = str;
      };

      openFirewall = mkOption {
        default = false;
        description = "Whether to open the TCP port in the firewall";
        type = bool;
      };

      plugins = mkOption {
        default = [ ];
        description = "List of Navidrome plugins";

        example = literalExpression ''
          with pkgs.navidromePlugins; [
            listenbrainz-daily-playlist
          ];
        '';

        type = listOf (
          addCheck package (p: p.isNavidromePlugin or false)
          // {
            description = "package that is a navidrome plugin";
            name = "navidrome plugin";
          }
        );
      };

      settings = mkOption {
        default = { };
        description = "Configuration for Navidrome, see <https://www.navidrome.org/docs/usage/configuration-options/> for supported values.";

        example = {
          MusicFolder = "/mnt/music";
        };

        type = submodule {
          options = {
            Address = mkOption {
              default = "127.0.0.1";
              description = "Address to run Navidrome on.";
              type = str;
            };

            EnableInsightsCollector = mkOption {
              default = false;
              description = "Enable anonymous usage data collection, see <https://www.navidrome.org/docs/getting-started/insights/> for details.";
              type = bool;
            };

            Plugins = {
              Enabled = mkOption {
                default = true;

                description = ''
                  Enable plugin support in navidrome.
                '';
              };

              Folder = mkOption {
                default = "${cfg.finalPackage}/share/plugins";
                defaultText = literalExpression "\"\${config.services.navidrome.finalPackage}/share/plugins\"";

                description = ''
                  The folder containing navidrome plugins.

                  This directory is automatically created from plugins defined in {option}`services.navidrome.plugins`.
                '';

                readOnly = true;
                type = str;
              };
            };

            Port = mkOption {
              default = 4533;
              description = "Port to run Navidrome on.";
              type = port;
            };
          };

          freeformType = settingsFormat.type;
        };
      };

      user = mkOption {
        default = "navidrome";
        description = "User under which Navidrome runs.";
        type = str;
      };
    };
  };

  config =
    let
      inherit (lib) mkIf optional getExe;
      WorkingDirectory = "/var/lib/navidrome";
    in
    mkIf cfg.enable {
      networking.firewall.allowedTCPPorts = mkIf cfg.openFirewall [ cfg.settings.Port ];

      systemd = {
        services.navidrome = {
          after = [ "network.target" ];
          description = "Navidrome Media Server";

          serviceConfig = {
            inherit WorkingDirectory;

            BindPaths =
              optional (cfg.settings ? DataFolder) cfg.settings.DataFolder
              ++ optional (cfg.settings ? CacheFolder) cfg.settings.CacheFolder
              ++ optional (cfg.settings ? Backup.Path) cfg.settings.Backup.Path;

            BindReadOnlyPaths = [
              # navidrome uses online services to download additional album metadata / covers
              "${config.security.pki.caBundle}:/etc/ssl/certs/ca-certificates.crt"
              builtins.storeDir
              "/etc"
            ]
            ++ optional (cfg.settings ? MusicFolder) cfg.settings.MusicFolder
            ++ lib.optionals config.services.resolved.enable [
              "/run/systemd/resolve/stub-resolv.conf"
              "/run/systemd/resolve/resolv.conf"
            ];

            CapabilityBoundingSet = "";
            EnvironmentFile = lib.mkIf (cfg.environmentFile != null) [ cfg.environmentFile ];

            ExecStart = ''
              ${getExe cfg.finalPackage} --configfile ${settingsFormat.generate "navidrome.json" cfg.settings}
            '';

            Group = cfg.group;
            LockPersonality = true;
            # 0.60.0 Taglib introduces WASM JIT that requires this
            MemoryDenyWriteExecute = false;
            PrivateDevices = true;
            PrivateUsers = true;
            ProtectClock = true;
            ProtectControlGroups = true;
            ProtectHome = true;
            ProtectHostname = true;
            ProtectKernelLogs = true;
            ProtectKernelModules = true;
            ProtectKernelTunables = true;
            ReadWritePaths = "";

            RestrictAddressFamilies = [
              "AF_UNIX"
              "AF_INET"
              "AF_INET6"
            ];

            RestrictNamespaces = true;
            RestrictRealtime = true;
            RootDirectory = "/run/navidrome";
            RuntimeDirectory = "navidrome";
            StateDirectory = "navidrome";
            SystemCallArchitectures = "native";

            SystemCallFilter = [
              "@system-service"
              "~@privileged"
            ];

            UMask = "0066";
            User = cfg.user;
          };

          wantedBy = [ "multi-user.target" ];
        };

        tmpfiles.settings.navidromeDirs = {
          "${cfg.settings.CacheFolder or (WorkingDirectory + "/cache")}"."d" = {
            inherit (cfg) user group;
            mode = "700";
          };

          "${cfg.settings.DataFolder or WorkingDirectory}"."d" = {
            inherit (cfg) user group;
            mode = "700";
          };

          "${cfg.settings.MusicFolder or (WorkingDirectory + "/music")}"."d" = {
            group = ":${cfg.group}";
            mode = ":700";
            user = ":${cfg.user}";
          };
        };
      };

      users.groups = mkIf (cfg.group == "navidrome") { navidrome = { }; };

      users.users = mkIf (cfg.user == "navidrome") {
        navidrome = {
          inherit (cfg) group;
          isSystemUser = true;
        };
      };
    };

  meta.maintainers = with maintainers; [
    fsnkty
    tebriel
  ];
}

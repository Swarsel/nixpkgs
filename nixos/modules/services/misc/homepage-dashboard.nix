{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.homepage-dashboard;
  # Define the settings format used for this program
  settingsFormat = pkgs.formats.yaml { };
in
{
  imports = [
    (lib.mkChangedOptionModule
      [ "services" "homepage-dashboard" "environmentFile" ]
      [ "services" "homepage-dashboard" "environmentFiles" ]
      (config: [ config.services.homepage-dashboard.environmentFile ])
    )
  ];

  options = {
    services.homepage-dashboard = {
      enable = lib.mkEnableOption "Homepage Dashboard, a highly customizable application dashboard";
      package = lib.mkPackageOption pkgs "homepage-dashboard" { };

      allowedHosts = lib.mkOption {
        default = "localhost:8082,127.0.0.1:8082";

        description = ''
          Hosts that homepage-dashboard will be running under.
          You will want to change this in order to acess homepage from anything other than localhost.
          see the upsream documentation:

          <https://gethomepage.dev/installation/#homepage_allowed_hosts>
        '';

        example = "example.com";
        type = lib.types.str;
      };

      bookmarks = lib.mkOption {
        inherit (settingsFormat) type;
        default = [ ];

        description = ''
          Homepage bookmarks configuration.

          See <https://gethomepage.dev/configs/bookmarks/>.
        '';

        # Defaults: https://github.com/gethomepage/homepage/blob/main/src/skeleton/bookmarks.yaml
        example = [
          {
            Developer = [
              {
                Github = [
                  {
                    abbr = "GH";
                    href = "https://github.com/";
                  }
                ];
              }
            ];
          }
          {
            Entertainment = [
              {
                YouTube = [
                  {
                    abbr = "YT";
                    href = "https://youtube.com/";
                  }
                ];
              }
            ];
          }
        ];
      };

      customCSS = lib.mkOption {
        default = "";

        description = ''
          Custom CSS for styling Homepage.

          See <https://gethomepage.dev/configs/custom-css-js/>.
        '';

        type = lib.types.lines;
      };

      customJS = lib.mkOption {
        default = "";

        description = ''
          Custom Javascript for Homepage.

          See <https://gethomepage.dev/configs/custom-css-js/>.
        '';

        type = lib.types.lines;
      };

      docker = lib.mkOption {
        inherit (settingsFormat) type;
        default = { };

        description = ''
          Homepage docker configuration.

          See <https://gethomepage.dev/configs/docker/>.
        '';
      };

      environmentFiles = lib.mkOption {
        default = [ ];

        description = ''
          A list of paths to environment files that contain environment variables to pass
          to the homepage-dashboard service, for the purpose of passing secrets to
          the service.

          See the upstream documentation:

          <https://gethomepage.dev/installation/docker/#using-environment-secrets>
        '';

        type = lib.types.listOf lib.types.path;
      };

      kubernetes = lib.mkOption {
        inherit (settingsFormat) type;
        default = { };

        description = ''
          Homepage kubernetes configuration.

          See <https://gethomepage.dev/configs/kubernetes/>.
        '';
      };

      listenPort = lib.mkOption {
        default = 8082;
        description = "Port for Homepage to bind to.";
        type = lib.types.port;
      };

      openFirewall = lib.mkOption {
        default = false;
        description = "Open ports in the firewall for Homepage.";
        type = lib.types.bool;
      };

      proxmox = lib.mkOption {
        inherit (settingsFormat) type;
        default = { };

        description = ''
          Homepage proxmox configuration.

          See <https://gethomepage.dev/configs/proxmox/>.
        '';
      };

      services = lib.mkOption {
        inherit (settingsFormat) type;
        default = [ ];

        description = ''
          Homepage services configuration.

          See <https://gethomepage.dev/configs/services/>.
        '';

        # Defaults: https://github.com/gethomepage/homepage/blob/main/src/skeleton/services.yaml
        example = [
          {
            "My First Group" = [
              {
                "My First Service" = {
                  description = "Homepage is awesome";
                  href = "http://localhost/";
                };
              }
            ];
          }
          {
            "My Second Group" = [
              {
                "My Second Service" = {
                  description = "Homepage is the best";
                  href = "http://localhost/";
                };
              }
            ];
          }
        ];
      };

      settings = lib.mkOption {
        inherit (settingsFormat) type;
        # Defaults: https://github.com/gethomepage/homepage/blob/main/src/skeleton/settings.yaml
        default = { };

        description = ''
          Homepage settings.

          See <https://gethomepage.dev/configs/settings/>.
        '';
      };

      widgets = lib.mkOption {
        inherit (settingsFormat) type;
        default = [ ];

        description = ''
          Homepage widgets configuration.

          See <https://gethomepage.dev/widgets/>.
        '';

        # Defaults: https://github.com/gethomepage/homepage/blob/main/src/skeleton/widgets.yaml
        example = [
          {
            resources = {
              cpu = true;
              disk = "/";
              memory = true;
            };
          }
          {
            search = {
              provider = "duckduckgo";
              target = "_blank";
            };
          }
        ];
      };
    };
  };

  config = lib.mkIf cfg.enable {
    environment.etc = {
      "homepage-dashboard/bookmarks.yaml".source = settingsFormat.generate "bookmarks.yaml" cfg.bookmarks;
      "homepage-dashboard/custom.css".text = cfg.customCSS;
      "homepage-dashboard/custom.js".text = cfg.customJS;
      "homepage-dashboard/docker.yaml".source = settingsFormat.generate "docker.yaml" cfg.docker;

      "homepage-dashboard/kubernetes.yaml".source =
        settingsFormat.generate "kubernetes.yaml" cfg.kubernetes;

      "homepage-dashboard/proxmox.yaml".source = settingsFormat.generate "proxmox.yaml" cfg.proxmox;
      "homepage-dashboard/services.yaml".source = settingsFormat.generate "services.yaml" cfg.services;
      "homepage-dashboard/settings.yaml".source = settingsFormat.generate "settings.yaml" cfg.settings;
      "homepage-dashboard/widgets.yaml".source = settingsFormat.generate "widgets.yaml" cfg.widgets;
    };

    networking.firewall = lib.mkIf cfg.openFirewall {
      allowedTCPPorts = [ cfg.listenPort ];
    };

    systemd.services.homepage-dashboard = {
      after = [ "network.target" ];
      description = "Homepage Dashboard";
      enableStrictShellChecks = true;

      environment = {
        HOMEPAGE_ALLOWED_HOSTS = cfg.allowedHosts;
        HOMEPAGE_CONFIG_DIR = "/etc/homepage-dashboard";
        LOG_TARGETS = "stdout";
        NIXPKGS_HOMEPAGE_CACHE_DIR = "/var/cache/homepage-dashboard";
        PORT = toString cfg.listenPort;
      };

      # Related:
      # * https://github.com/NixOS/nixpkgs/issues/346016 ("homepage-dashboard: cache dir is not cleared upon version upgrade")
      # * https://github.com/gethomepage/homepage/discussions/4560 ("homepage NixOS package does not clear cache on upgrade leaving broken state")
      # * https://github.com/vercel/next.js/discussions/58864 ("Feature Request: Allow configuration of cache dir")
      preStart = ''
        rm -rf "''${NIXPKGS_HOMEPAGE_CACHE_DIR:?}"/*
      '';

      serviceConfig = {
        CacheDirectory = "homepage-dashboard";
        CapabilityBoundingSet = "";
        DeviceAllow = "";
        DevicePolicy = "closed";
        # hardening
        DynamicUser = true;
        EnvironmentFile = cfg.environmentFiles;
        ExecStart = lib.getExe cfg.package;
        LockPersonality = true;
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateMounts = true;
        PrivateTmp = true;
        PrivateUsers = true;
        # cpu widget requires access to /proc
        ProcSubset = if lib.any (widget: widget.resources.cpu or false) cfg.widgets then "all" else "pid";
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
        Restart = "on-failure";

        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
          "AF_UNIX"
          "AF_NETLINK"
        ];

        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        StateDirectory = "homepage-dashboard";
        SystemCallArchitectures = "native";

        SystemCallFilter = [
          "@system-service"
          "~@resources"
        ];

        Type = "simple";
        UMask = "0077";
      };

      wantedBy = [ "multi-user.target" ];
    };
  };
}

{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.cockpit;
  inherit (lib)
    types
    mkEnableOption
    mkOption
    mkIf
    mkPackageOption
    ;
  settingsFormat = pkgs.formats.ini { };

  pathPkgs = [ cfg.package ] ++ cfg.plugins;

  resourcesEnv = pkgs.buildEnv {
    name = "cockpit-plugins";
    paths = pathPkgs;
    pathsToLink = [ "/share/cockpit" ];
  };

  depsEnv = pkgs.buildEnv {
    name = "cockpit-plugins-env";
    paths = lib.concatMap (p: p.passthru.cockpitPath or [ ]) pathPkgs;

    pathsToLink = [
      "/bin"
      "/share"
      "/lib"
    ];
  };

  share = pkgs.buildEnv {
    name = "cockpit-share";

    paths = [
      resourcesEnv
      depsEnv
    ];

    pathsToLink = [ "/share" ];
  };
in
{
  options = {
    services.cockpit = {
      enable = mkEnableOption "Cockpit";

      package = mkPackageOption pkgs "Cockpit" {
        default = [ "cockpit" ];
      };

      allowed-origins = lib.mkOption {
        default = [ ];

        description = ''
          List of allowed origins.

          Maps to the WebService.Origins setting and allows merging from multiple modules.
        '';

        type = types.listOf types.str;
      };

      openFirewall = mkOption {
        default = false;
        description = "Open port for cockpit.";
        type = types.bool;
      };

      plugins = lib.mkOption {
        default = [ ];

        description = ''
          List of cockpit plugins.

          This add the passthru.cockpitPath of the packages to the systemd cockpit service.
        '';

        example = lib.literalExpression ''
          [
            pkgs.cockpit-zfs
          ]
        '';

        type = types.listOf types.package;
      };

      port = mkOption {
        default = 9090;
        description = "Port where cockpit will listen.";
        type = types.port;
      };

      settings = lib.mkOption {
        default = { };

        description = ''
          Settings for cockpit that will be saved in /etc/cockpit/cockpit.conf.

          See the [documentation](https://cockpit-project.org/guide/latest/cockpit.conf.5.html), that is also available with `man cockpit.conf.5` for details.
        '';

        type = settingsFormat.type;
      };

      showBanner = mkOption {
        default = true;
        description = "Whether to add the Cockpit banner to the issue and motd files.";
        example = false;
        type = types.bool;
      };
    };
  };

  config = mkIf cfg.enable {
    environment.etc = {
      # Add plugins dependencies
      "cockpit/bin".source = "${depsEnv}/bin";
      # generate cockpit settings
      "cockpit/cockpit.conf".source = settingsFormat.generate "cockpit.conf" cfg.settings;
      "cockpit/lib".source = "${depsEnv}/lib";
      # Add plugins in discoverable folder
      "cockpit/share".source = "${share}/share";

      # Add "Web console: ..." line to issue and MOTD
      "issue.d/cockpit.issue" = {
        enable = cfg.showBanner;
        source = "/run/cockpit/issue";
      };

      "motd.d/cockpit" = {
        enable = cfg.showBanner;
        source = "/run/cockpit/issue";
      };
    };

    networking.firewall.allowedTCPPorts = mkIf cfg.openFirewall [ cfg.port ];

    security.pam.services.cockpit = {
      startSession = true;
    };

    services.cockpit.allowed-origins = [
      "https://localhost:${toString config.services.cockpit.port}"
    ];

    services.cockpit.settings.WebService = {
      LoginTo = lib.mkDefault false;
      Origins = builtins.concatStringsSep " " config.services.cockpit.allowed-origins;
    };

    systemd.packages = [ cfg.package ];

    # Enable connecting to remote hosts from the login page
    systemd.services = mkIf (cfg.settings.WebService.LoginTo or false) {
      "cockpit-wsinstance-http".path = [
        config.programs.ssh.package
        cfg.package
      ];

      "cockpit-wsinstance-https@".path = [
        config.programs.ssh.package
        cfg.package
      ];
    };

    systemd.sockets.cockpit = {
      listenStreams = [
        "" # workaround so it doesn't listen on both ports caused by the runtime merging
        (toString cfg.port)
      ];

      wantedBy = [ "multi-user.target" ];
    };

    systemd.tmpfiles.rules = [
      # From $out/lib/tmpfiles.d/cockpit-tmpfiles.conf
      "C /run/cockpit/inactive.motd 0640 root root - ${cfg.package}/share/cockpit/motd/inactive.motd"
      "f /run/cockpit/active.motd   0640 root root -"
      "L+ /run/cockpit/motd - - - - inactive.motd"
      "d /etc/cockpit/ws-certs.d 0600 root root 0"
    ];

    warnings =
      lib.optional (lib.versionOlder cfg.package.version "360" && cfg.settings.WebService.LoginTo or true)
        ''
          The current Cockpit version is older than 360, and logging into other
          hosts is enabled. This makes the system vulnerable to CVE-2026-4631,
          which allows unauthenticated users on the network that can reach Cockpit
          to gain code execution on the machine. Please upgrade your Cockpit
          package or disable logging into other hosts by setting the option:

            services.cockpit.settings.WebService.LoginTo = false;
        '';
  };

  meta.maintainers = pkgs.cockpit.meta.maintainers;
}

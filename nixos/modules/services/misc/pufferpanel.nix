{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.pufferpanel;
in
{
  options.services.pufferpanel = {
    enable = lib.mkOption {
      default = false;

      description = ''
        Whether to enable PufferPanel game management server.

        Note that [PufferPanel templates] and binaries downloaded by PufferPanel
        expect [FHS environment]. It is possible to set {option}`package` option
        to use PufferPanel wrapper with FHS environment. For example, to use
        `Download Game from Steam` and `Download Java` template operations:
        ```Nix
        { lib, pkgs, ... }: {
          services.pufferpanel = {
            enable = true;
            extraPackages = with pkgs; [ bash curl gawk gnutar gzip ];
            package = pkgs.buildFHSEnv {
              name = "pufferpanel-fhs";
              runScript = lib.getExe pkgs.pufferpanel;
              targetPkgs = pkgs': with pkgs'; [ icu openssl zlib ];
            };
          };
        }
        ```

        [PufferPanel templates]: https://github.com/PufferPanel/templates
        [FHS environment]: https://wikipedia.org/wiki/Filesystem_Hierarchy_Standard
      '';

      type = lib.types.bool;
    };

    package = lib.mkPackageOption pkgs "pufferpanel" { };

    environment = lib.mkOption {
      default = { };

      description = ''
        Environment variables to set for the service. Secrets should be
        specified using {option}`environmentFile`.

        Refer to the [PufferPanel source code][] for the list of available
        configuration options. Variable name is an upper-cased configuration
        entry name with underscores instead of dots, prefixed with `PUFFER_`.
        For example, `panel.settings.companyName` entry can be set using
        {env}`PUFFER_PANEL_SETTINGS_COMPANYNAME`.

        When running with panel enabled (configured with `PUFFER_PANEL_ENABLE`
        environment variable), it is recommended disable registration using
        `PUFFER_PANEL_REGISTRATIONENABLED` environment variable (registration is
        enabled by default). To create the initial administrator user, run
        {command}`pufferpanel --workDir /var/lib/pufferpanel user add --admin`.

        Some options override corresponding settings set via web interface (e.g.
        `PUFFER_PANEL_REGISTRATIONENABLED`). Those options can be temporarily
        toggled or set in settings but do not persist between restarts.

        [PufferPanel source code]: https://github.com/PufferPanel/PufferPanel/blob/master/config/entries.go
      '';

      example = lib.literalExpression ''
        {
          PUFFER_WEB_HOST = ":8080";
          PUFFER_DAEMON_SFTP_HOST = ":5657";
          PUFFER_DAEMON_CONSOLE_BUFFER = "1000";
          PUFFER_DAEMON_CONSOLE_FORWARD = "true";
          PUFFER_PANEL_REGISTRATIONENABLED = "false";
        }
      '';

      type = lib.types.attrsOf lib.types.str;
    };

    environmentFile = lib.mkOption {
      default = null;

      description = ''
        File to load environment variables from. Loaded variables override
        values set in {option}`environment`.
      '';

      type = lib.types.nullOr lib.types.path;
    };

    extraGroups = lib.mkOption {
      default = [ ];

      description = ''
        Additional groups for the systemd service.
      '';

      example = [ "podman" ];
      type = lib.types.listOf lib.types.str;
    };

    extraPackages = lib.mkOption {
      default = [ ];

      description = ''
        Packages to add to the PATH environment variable. Both the {file}`bin`
        and {file}`sbin` subdirectories of each package are added.
      '';

      example = lib.literalExpression "[ pkgs.jre ]";
      type = lib.types.listOf lib.types.package;
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.pufferpanel = {
      after = [ "network.target" ];
      description = "PufferPanel game management server";
      environment = cfg.environment;
      path = cfg.extraPackages;

      # Note that we export environment variables for service directories if the
      # value is not set. An empty environment variable is considered to be set.
      # E.g.
      #   export PUFFER_LOGS=${PUFFER_LOGS-$LOGS_DIRECTORY}
      # would set PUFFER_LOGS to $LOGS_DIRECTORY if PUFFER_LOGS environment
      # variable is not defined.
      script = ''
        ${lib.concatLines (
          lib.mapAttrsToList
            (name: value: ''
              export ${name}="''${${name}-${value}}"
            '')
            {
              PUFFER_DAEMON_DATA_BINARIES = "$STATE_DIRECTORY/binaries";
              PUFFER_DAEMON_DATA_CACHE = "$CACHE_DIRECTORY";
              PUFFER_DAEMON_DATA_SERVERS = "$STATE_DIRECTORY/servers";
              PUFFER_LOGS = "$LOGS_DIRECTORY";
            }
        )}
        exec ${lib.getExe cfg.package} run --workDir "$STATE_DIRECTORY"
      '';

      serviceConfig = {
        CacheDirectory = "pufferpanel";
        CacheDirectoryMode = "0700";
        CapabilityBoundingSet = [ "" ];
        DeviceAllow = [ "" ];
        DevicePolicy = "closed";
        DynamicUser = true;
        EnvironmentFile = cfg.environmentFile;
        # Command "pufferpanel shutdown --pid $MAINPID" sends SIGTERM (code 15)
        # to the main process and waits for termination. This is essentially
        # KillMode=mixed we are using here. See
        # https://freedesktop.org/software/systemd/man/systemd.kill.html#KillMode=
        KillMode = "mixed";
        LockPersonality = true;
        LogsDirectory = "pufferpanel";
        LogsDirectoryMode = "0700";
        PrivateDevices = true;
        PrivateUsers = true;
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
          "AF_INET"
          "AF_INET6"
          "AF_UNIX"
        ];

        RestrictNamespaces = [
          "user"
          "mnt"
        ]; # allow buildFHSEnv

        RestrictRealtime = true;
        StateDirectory = "pufferpanel";
        StateDirectoryMode = "0700";
        SupplementaryGroups = cfg.extraGroups;
        Type = "simple";
        UMask = "0077";
      };

      wantedBy = [ "multi-user.target" ];
    };
  };

  meta.maintainers = [ lib.maintainers.tie ];
}

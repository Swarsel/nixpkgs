{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkPackageOption
    mkOption
    types
    mkIf
    ;
  json = pkgs.formats.json { };
  cfg = config.services.renovate;
  generateValidatedConfig =
    name: value:
    pkgs.callPackage (
      { jq, runCommand }:
      runCommand name
        {
          nativeBuildInputs = [
            jq
            cfg.package
          ];

          passAsFile = [ "value" ];
          preferLocalBuild = true;
          value = builtins.toJSON value;
        }
        ''
          jq . "$valuePath"> $out
          renovate-config-validator $out
        ''
    ) { };
  generateConfig = if cfg.validateSettings then generateValidatedConfig else json.generate;
in
{
  options.services.renovate = {
    enable = mkEnableOption "renovate";
    package = mkPackageOption pkgs "renovate" { };

    credentials = mkOption {
      default = { };

      description = ''
        Allows configuring environment variable credentials for renovate, read from files.
        This should always be used for passing confidential data to renovate.
      '';

      example = {
        RENOVATE_TOKEN = "/etc/renovate/token";
      };

      type = with types; attrsOf path;
    };

    environment = mkOption {
      default = { };

      description = ''
        Extra environment variables to export to the Renovate process
        from the systemd unit configuration.

        See <https://docs.renovatebot.com/config-overview> for available environment variables.
      '';

      example = {
        LOG_LEVEL = "debug";
      };

      type =
        with types;
        attrsOf (
          nullOr (oneOf [
            str
            path
            package
          ])
        );
    };

    runtimePackages = mkOption {
      default = [ ];
      description = "Packages available to renovate.";
      type = with types; listOf package;
    };

    schedule = mkOption {
      default = null;
      description = "How often to run renovate. See {manpage}`systemd.time(7)` for the format.";
      example = "*:0/10";
      type = with types; nullOr str;
    };

    settings = mkOption {
      default = { };

      description = ''
        Renovate's global configuration.
        If you want to pass secrets to renovate, please use {option}`services.renovate.credentials` for that.

        See <https://docs.renovatebot.com/config-overview> for available settings.
      '';

      example = {
        endpoint = "https://git.example.com";
        gitAuthor = "Renovate <renovate@example.com>";
        platform = "gitea";
      };

      type = json.type;
    };

    validateSettings = mkOption {
      default = true;
      description = "Whether to run renovate's config validator on the built configuration.";
      type = types.bool;
    };
  };

  config = mkIf cfg.enable {
    services.renovate = {
      environment = {
        HOME = "/var/lib/renovate";
        RENOVATE_CONFIG_FILE = generateConfig "renovate-config.json" cfg.settings;
      };

      settings = {
        baseDir = "/var/lib/renovate";
        cacheDir = "/var/cache/renovate";
      };
    };

    systemd.services.renovate = {
      inherit (cfg) environment;
      after = [ "network.target" ];
      description = "Renovate dependency updater";
      documentation = [ "https://docs.renovatebot.com/" ];

      path = [
        config.systemd.package
        pkgs.git
      ]
      ++ cfg.runtimePackages;

      script = ''
        ${lib.concatStringsSep "\n" (
          map (name: ''
            ${name}="$(systemd-creds cat 'SECRET-${name}')"
            export ${name}
          '') (lib.attrNames cfg.credentials)
        )}
        exec ${lib.escapeShellArg (lib.getExe cfg.package)}
      '';

      serviceConfig = {
        CacheDirectory = "renovate";
        # Hardening
        CapabilityBoundingSet = [ "" ];
        DeviceAllow = [ "" ];
        DynamicUser = true;
        Group = "renovate";
        LoadCredential = lib.mapAttrsToList (name: value: "SECRET-${name}:${value}") cfg.credentials;
        LockPersonality = true;
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

        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
          "AF_UNIX"
        ];

        RestrictNamespaces = true;
        RestrictRealtime = true;
        StateDirectory = "renovate";
        SystemCallArchitectures = "native";
        UMask = "0077";
        User = "renovate";
      };

      startAt = lib.optional (cfg.schedule != null) cfg.schedule;
    };
  };

  meta.maintainers = with lib.maintainers; [
    marie
    natsukium
  ];
}

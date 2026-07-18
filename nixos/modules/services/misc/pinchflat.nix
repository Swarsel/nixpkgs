{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.pinchflat;
  inherit (lib)
    mkEnableOption
    mkPackageOption
    mkOption
    types
    mkIf
    getExe
    literalExpression
    optional
    attrValues
    mapAttrs
    ;

  stateDir = "/var/lib/pinchflat";
in
{
  options = {
    services.pinchflat = {
      enable = mkEnableOption "pinchflat";
      package = mkPackageOption pkgs "pinchflat" { };

      extraConfig = mkOption {
        default = { };

        description = ''
          The configuration of Pinchflat is handled through environment variables.
          The available configuration options can be found in [the Pinchflat README](https://github.com/kieraneglin/pinchflat/README.md#environment-variables).
        '';

        example = literalExpression ''
          {
            YT_DLP_WORKER_CONCURRENCY = 1;
          }
        '';

        type =
          with types;
          attrsOf (
            nullOr (oneOf [
              bool
              int
              str
            ])
          );
      };

      group = lib.mkOption {
        default = "pinchflat";

        description = ''
          Group under which Pinchflat runs.
        '';

        type = lib.types.str;
      };

      logLevel = mkOption {
        default = "info";
        description = "Log level for Pinchflat.";

        type = types.enum [
          "debug"
          "info"
          "warning"
          "error"
        ];
      };

      mediaDir = mkOption {
        default = "${stateDir}/media";
        description = "The directory into which Pinchflat downloads videos.";
        type = types.path;
      };

      openFirewall = mkOption {
        default = false;
        description = "Open ports in the firewall for the Pinchflat web interface";
        type = types.bool;
      };

      port = mkOption {
        default = 8945;
        description = "Port on which the Pinchflat web interface is available.";
        type = types.port;
      };

      secretsFile = mkOption {
        default = null;

        description = ''
          Secrets like {env}`SECRET_KEY_BASE` and {env}`BASIC_AUTH_PASSWORD`
          should be passed to the service without adding them to the world-readable Nix store.

          Note that either this file needs to be available on the host on which `pinchflat` is running,
          or the option `selfhosted` must be `true`.
          Further, {env}`SECRET_KEY_BASE` has a minimum length requirement of 64 bytes.
          One way to generate such a secret is to use `openssl rand -hex 64`.

          As an example, the contents of the file might look like this:
          ```
          SECRET_KEY_BASE=...copy-paste a secret token here...
          BASIC_AUTH_USERNAME=...basic auth username...
          BASIC_AUTH_PASSWORD=...basic auth password...
          ```
        '';

        example = "/run/secrets/pinchflat";
        type = with types; nullOr path;
      };

      selfhosted = mkOption {
        default = false;
        description = "Use a weak secret. If true, you are not required to provide a {env}`SECRET_KEY_BASE` through the `secretsFile` option. Do not use this option in production!";
        type = types.bool;
      };

      user = lib.mkOption {
        default = "pinchflat";

        description = ''
          User account under which Pinchflat runs.
        '';

        type = lib.types.str;
      };
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.selfhosted || !isNull cfg.secretsFile;
        message = "Either `selfhosted` must be true, or a `secretsFile` must be configured.";
      }
    ];

    networking.firewall = mkIf cfg.openFirewall {
      allowedTCPPorts = [ cfg.port ];
    };

    systemd.services.pinchflat = {
      after = [ "network.target" ];
      description = "pinchflat";

      serviceConfig = {
        Environment = [
          "PORT=${toString cfg.port}"
          "MEDIA_PATH=${cfg.mediaDir}"
          "CONFIG_PATH=${stateDir}"
          "DATABASE_PATH=${stateDir}/db/pinchflat.db"
          "LOG_PATH=${stateDir}/logs/pinchflat.log"
          "METADATA_PATH=${stateDir}/metadata"
          "EXTRAS_PATH=${stateDir}/extras"
          "TMPFILE_PATH=${stateDir}/tmp"
          "TZ_DATA_PATH=${stateDir}/extras/elixir_tz_data"
          "LOG_LEVEL=${cfg.logLevel}"
          "PHX_SERVER=true"
        ]
        ++ optional cfg.selfhosted [ "RUN_CONTEXT=selfhosted" ]
        ++ optional (!isNull config.time.timeZone) "TZ=${config.time.timeZone}"
        ++ attrValues (mapAttrs (name: value: name + "=" + toString value) cfg.extraConfig);

        EnvironmentFile = optional (cfg.secretsFile != null) cfg.secretsFile;
        ExecStart = "${getExe cfg.package} start";
        ExecStartPre = "${lib.getExe' cfg.package "migrate"}";
        Group = cfg.group;
        Restart = "on-failure";
        StateDirectory = baseNameOf stateDir;
        Type = "simple";
        User = cfg.user;
      };

      wantedBy = [ "multi-user.target" ];
    };

    users.groups = lib.mkIf (cfg.group == "pinchflat") {
      pinchflat = { };
    };

    users.users = lib.mkIf (cfg.user == "pinchflat") {
      pinchflat = {
        group = cfg.group;
        isSystemUser = true;
      };
    };
  };
}

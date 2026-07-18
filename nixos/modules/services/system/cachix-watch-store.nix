{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.cachix-watch-store;
in
{
  options.services.cachix-watch-store = {
    enable = lib.mkEnableOption "Cachix Watch Store: <https://docs.cachix.org>";
    package = lib.mkPackageOption pkgs "cachix" { };

    cacheName = lib.mkOption {
      description = "Cachix binary cache name";
      type = lib.types.str;
    };

    cachixTokenFile = lib.mkOption {
      description = ''
        Required file that needs to contain the cachix auth token.
      '';

      type = lib.types.path;
    };

    compressionLevel = lib.mkOption {
      default = null;
      description = "The compression level for ZSTD compression (between 0 and 16)";
      type = lib.types.nullOr (lib.types.ints.between 0 16);
    };

    host = lib.mkOption {
      default = null;
      description = "Cachix host to connect to";
      type = lib.types.nullOr lib.types.str;
    };

    jobs = lib.mkOption {
      default = null;
      description = "Number of threads used for pushing store paths";
      type = lib.types.nullOr lib.types.ints.positive;
    };

    signingKeyFile = lib.mkOption {
      default = null;

      description = ''
        Optional file containing a self-managed signing key to sign uploaded store paths.
      '';

      type = lib.types.nullOr lib.types.path;
    };

    verbose = lib.mkOption {
      default = false;
      description = "Enable verbose output";
      type = lib.types.bool;
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.cachix-watch-store-agent = {
      after = [ "network-online.target" ];
      description = "Cachix watch store Agent";
      path = [ config.nix.package ];

      script =
        let
          command = [
            "${cfg.package}/bin/cachix"
          ]
          ++ (lib.optional cfg.verbose "--verbose")
          ++ (lib.optionals (cfg.host != null) [
            "--host"
            cfg.host
          ])
          ++ [ "watch-store" ]
          ++ (lib.optionals (cfg.compressionLevel != null) [
            "--compression-level"
            (toString cfg.compressionLevel)
          ])
          ++ (lib.optionals (cfg.jobs != null) [
            "--jobs"
            (toString cfg.jobs)
          ])
          ++ [ cfg.cacheName ];
        in
        ''
          export CACHIX_AUTH_TOKEN="$(<"$CREDENTIALS_DIRECTORY/cachix-token")"
          ${lib.optionalString (
            cfg.signingKeyFile != null
          ) ''export CACHIX_SIGNING_KEY="$(<"$CREDENTIALS_DIRECTORY/signing-key")"''}
          ${lib.escapeShellArgs command}
        '';

      serviceConfig = {
        DynamicUser = true;
        # we don't want to kill children processes as those are deployments
        KillMode = "process";

        LoadCredential = [
          "cachix-token:${toString cfg.cachixTokenFile}"
        ]
        ++ lib.optional (cfg.signingKeyFile != null) "signing-key:${toString cfg.signingKeyFile}";

        Restart = "on-failure";
        # don't put too much stress on the machine when restarting
        RestartSec = 1;
      };

      unitConfig = {
        # allow to restart indefinitely
        StartLimitIntervalSec = 0;
      };

      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
    };
  };

  meta = {
    maintainers = with lib.maintainers; [
      domenkozar
      jfroche
      sandydoo
    ];
  };
}

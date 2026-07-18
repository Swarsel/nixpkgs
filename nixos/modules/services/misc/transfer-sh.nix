{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.transfer-sh;
  inherit (lib)
    mkDefault
    mkEnableOption
    mkPackageOption
    mkIf
    mkOption
    types
    mapAttrs
    isBool
    getExe
    boolToString
    optionalAttrs
    ;
in
{
  options.services.transfer-sh = {
    enable = mkEnableOption "Easy and fast file sharing from the command-line";
    package = mkPackageOption pkgs "transfer-sh" { };

    provider = mkOption {
      default = "local";
      description = "Storage providers to use";

      type = types.enum [
        "local"
        "s3"
        "storj"
        "gdrive"
      ];
    };

    secretFile = mkOption {
      default = null;

      description = ''
        Path to file containing environment variables.
        Useful for passing down secrets.
        Some variables that can be considered secrets are:
         - AWS_ACCESS_KEY
         - AWS_ACCESS_KEY
         - TLS_PRIVATE_KEY
         - HTTP_AUTH_HTPASSWD
      '';

      example = "/run/secrets/transfer-sh.env";
      type = types.nullOr types.path;
    };

    settings = mkOption {
      default = { };

      description = ''
        Additional configuration for transfer-sh, see
        <https://github.com/dutchcoders/transfer.sh#usage-1>
        for supported values.

        For secrets use secretFile option instead.
      '';

      example = {
        BASEDIR = "/var/lib/transfer.sh";
        LISTENER = ":8080";
        TLS_LISTENER_ONLY = false;
      };

      type = types.submodule {
        freeformType =
          with types;
          attrsOf (oneOf [
            bool
            int
            str
          ]);
      };
    };
  };

  config =
    let
      localProvider = (cfg.provider == "local");
      stateDirectory = "/var/lib/transfer.sh";
    in
    mkIf cfg.enable {
      services.transfer-sh.settings = {
        LISTENER = mkDefault ":8080";
      }
      // optionalAttrs localProvider {
        BASEDIR = mkDefault stateDirectory;
      };

      systemd.services.transfer-sh = {
        after = [ "network.target" ];
        environment = mapAttrs (_: v: if isBool v then boolToString v else toString v) cfg.settings;

        serviceConfig = {
          DevicePolicy = "closed";
          DynamicUser = true;
          ExecStart = "${getExe cfg.package} --provider ${cfg.provider}";
          LockPersonality = true;
          MemoryDenyWriteExecute = true;
          PrivateDevices = true;
          PrivateUsers = true;
          ProtectClock = true;
          ProtectControlGroups = true;
          ProtectHostname = true;
          ProtectKernelLogs = true;
          ProtectKernelModules = true;
          ProtectKernelTunables = true;
          ProtectProc = "invisible";

          RestrictAddressFamilies = [
            "AF_INET"
            "AF_INET6"
          ];

          RestrictNamespaces = true;
          RestrictRealtime = true;
          StateDirectory = baseNameOf stateDirectory;
          SystemCallArchitectures = [ "native" ];
          SystemCallFilter = [ "@system-service" ];
        }
        // optionalAttrs (cfg.secretFile != null) {
          EnvironmentFile = cfg.secretFile;
        }
        // optionalAttrs localProvider {
          ReadWritePaths = cfg.settings.BASEDIR;
        };

        wantedBy = [ "multi-user.target" ];
      };
    };

  meta.maintainers = with lib.maintainers; [ ocfox ];
}

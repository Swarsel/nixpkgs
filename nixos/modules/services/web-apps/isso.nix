{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    types
    literalExpression
    ;

  cfg = config.services.isso;

  settingsFormat = pkgs.formats.ini { };
  configFile = settingsFormat.generate "isso.conf" cfg.settings;
in
{

  options = {
    services.isso = {
      enable = mkEnableOption ''
        isso, a commenting server similar to Disqus.

        Note: The application's author suppose to run isso behind a reverse proxy.
        The embedded solution offered by NixOS is also only suitable for small installations
        below 20 requests per second
      '';

      secretFile = mkOption {
        default = null;

        description = ''
          A file containing secrets as environment variables that will be used in the configuration.
          See [the documentation](https://isso-comments.de/docs/reference/server-config/#environment-variables) for details.
        '';

        example = "/run/secrets/isso.env";
        type = types.nullOr types.str;
      };

      settings = mkOption {
        description = ''
          Configuration for `isso`.

          See [Isso Server Configuration](https://posativ.org/isso/docs/configuration/server/)
          for supported values.
          You can set secrets using the secretFile option with environment variables following
          [the documentation](https://isso-comments.de/docs/reference/server-config/#environment-variables).
        '';

        example = literalExpression ''
          {
            general = {
              host = "http://localhost";
            };
          }
        '';

        type = types.submodule {
          freeformType = settingsFormat.type;
        };
      };
    };
  };

  config = mkIf cfg.enable {
    services.isso.settings.general.dbpath = lib.mkDefault "/var/lib/isso/comments.db";

    systemd.services.isso = {
      description = "isso, a commenting server similar to Disqus";

      serviceConfig = {
        # Hardening
        CapabilityBoundingSet = [ "" ];
        DeviceAllow = [ "" ];
        DynamicUser = true;
        EnvironmentFile = mkIf (cfg.secretFile != null) [ cfg.secretFile ];

        ExecStart = ''
          ${pkgs.isso}/bin/isso -c ${configFile}
        '';

        Group = "isso";
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
        Restart = "on-failure";
        RestartSec = 1;

        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
        ];

        RestrictNamespaces = true;
        RestrictRealtime = true;
        StateDirectory = "isso";
        SystemCallArchitectures = "native";

        SystemCallFilter = [
          "@system-service"
          "~@privileged"
          "~@resources"
        ];

        UMask = "0077";
        User = "isso";
      };

      wantedBy = [ "multi-user.target" ];
    };
  };
}

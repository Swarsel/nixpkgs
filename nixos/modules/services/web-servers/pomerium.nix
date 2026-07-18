{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  format = pkgs.formats.yaml { };
in
{
  options.services.pomerium = {
    enable = mkEnableOption "the Pomerium authenticating reverse proxy";

    configFile = mkOption {
      default = null;
      description = "Path to Pomerium config YAML. If set, overrides services.pomerium.settings.";
      type = with types; nullOr path;
    };

    secretsFile = mkOption {
      default = null;

      description = ''
        Path to file containing secrets for Pomerium, in systemd
        EnvironmentFile format. See the {manpage}`systemd.exec(5)` man page.
      '';

      type = with types; nullOr path;
    };

    settings = mkOption {
      default = { };

      description = ''
        The contents of Pomerium's config.yaml, in Nix expressions.

        Specifying configFile will override this in its entirety.

        See [the Pomerium
        configuration reference](https://pomerium.io/reference/) for more information about what to put
        here.
      '';

      type = format.type;
    };

    useACMEHost = mkOption {
      default = null;

      description = ''
        If set, use a NixOS-generated ACME certificate with the specified name.

        Note that this will require you to use a non-HTTP-based challenge, or
        disable Pomerium's in-built HTTP redirect server by setting
        http_redirect_addr to null and use a different HTTP server for serving
        the challenge response.

        If you're using an HTTP-based challenge, you should use the
        Pomerium-native autocert option instead.
      '';

      type = with types; nullOr str;
    };
  };

  config =
    let
      cfg = config.services.pomerium;
      cfgFile =
        if cfg.configFile != null then cfg.configFile else (format.generate "pomerium.yaml" cfg.settings);
    in
    mkIf cfg.enable {
      systemd.services.pomerium = {
        after = [
          "network.target"
        ]
        ++ (optional (cfg.useACMEHost != null) "acme-${cfg.useACMEHost}.service");

        description = "Pomerium authenticating reverse proxy";

        environment = optionalAttrs (cfg.useACMEHost != null) {
          CERTIFICATE_FILE = "fullchain.pem";
          CERTIFICATE_KEY_FILE = "key.pem";
        };

        script = ''
          if [[ -v CREDENTIALS_DIRECTORY ]]; then
            cd "$CREDENTIALS_DIRECTORY"
          fi
          exec "${pkgs.pomerium}/bin/pomerium" -config "${cfgFile}"
        '';

        serviceConfig = {
          AmbientCapabilities = [ "CAP_NET_BIND_SERVICE" ];
          CapabilityBoundingSet = [ "CAP_NET_BIND_SERVICE" ];
          DevicePolicy = "closed";
          DynamicUser = true;
          EnvironmentFile = cfg.secretsFile;

          LoadCredential = optionals (cfg.useACMEHost != null) [
            "fullchain.pem:/var/lib/acme/${cfg.useACMEHost}/fullchain.pem"
            "key.pem:/var/lib/acme/${cfg.useACMEHost}/key.pem"
          ];

          LockPersonality = true;
          MemoryDenyWriteExecute = false; # breaks LuaJIT
          NoNewPrivileges = true;
          PrivateDevices = true;
          PrivateTmp = true;
          PrivateUsers = false; # breaks CAP_NET_BIND_SERVICE
          ProtectControlGroups = true;
          ProtectHome = true;
          ProtectKernelLogs = true;
          ProtectKernelModules = true;
          ProtectKernelTunables = true;
          ProtectSystem = "strict";
          RestrictAddressFamilies = "AF_UNIX AF_INET AF_INET6 AF_NETLINK";
          RestrictNamespaces = true;
          RestrictRealtime = true;
          RestrictSUIDSGID = true;
          StateDirectory = [ "pomerium" ];
          SystemCallArchitectures = "native";
        };

        startLimitIntervalSec = 60;
        wantedBy = [ "multi-user.target" ];

        wants = [
          "network.target"
        ]
        ++ (optional (cfg.useACMEHost != null) "acme-${cfg.useACMEHost}.service");
      };

      # postRun hooks on cert renew can't be used to restart Nginx since renewal
      # runs as the unprivileged acme user. sslTargets are added to wantedBy + before
      # which allows the acme-order-renew-$cert.target to signify the successful updating
      # of certs end-to-end.
      systemd.services.pomerium-config-reload = mkIf (cfg.useACMEHost != null) {
        after = [ "acme-order-renew-${cfg.useACMEHost}.service" ];

        serviceConfig = {
          ExecCondition = "/run/current-system/systemd/bin/systemctl -q is-active pomerium.service";
          ExecStart = "/run/current-system/systemd/bin/systemctl --no-block restart pomerium.service";
          TimeoutSec = 60;
          Type = "oneshot";
        };

        # Block reloading if not all certs exist yet.
        unitConfig.ConditionPathExists = [
          "${config.security.acme.certs.${cfg.useACMEHost}.directory}/fullchain.pem"
        ];

        # TODO(lukegb): figure out how to make config reloading work with credentials.
        wantedBy = [
          "acme-order-renew-${cfg.useACMEHost}.service"
          "multi-user.target"
        ];
      };
    };
}

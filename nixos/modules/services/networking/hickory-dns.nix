{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.hickory-dns;
  toml = pkgs.formats.toml { };

  zoneType = lib.types.submodule (
    { config, ... }:
    {
      options = with lib; {
        file = mkOption {
          default = if config.zone_type != "External" then "${config.zone}.zone" else null;
          defaultText = literalExpression ''if config.zone_type != "External" then "''${config.zone}.zone" else null'';

          description = ''
            Path to the .zone file.
            If not fully-qualified, this path will be interpreted relative to the `directory` option.
            If omitted, defaults to the value of the `zone` option suffixed with ".zone" when `zone_type` isn't External; otherwise, defaults to `null`.
          '';

          type = types.nullOr (types.either types.path types.str);
        };

        zone = mkOption {
          description = ''
            Zone name, like "example.com", "localhost", or "0.0.127.in-addr.arpa".
          '';

          type = types.str;
        };

        zone_type = mkOption {
          default = "Primary";

          description = ''
            One of:
            - "Primary" (the master, authority for the zone).
            - "Secondary" (the slave, replicated from the primary).
            - "External" (a cached zone that queries other nameservers).

            For more details about these zone types, consult the documentation for BIND,
            though note that hickory-dns supports only a subset of BIND's zone types:
            <https://bind9.readthedocs.io/en/v9_18_4/reference.html#type>
          '';

          type = types.enum [
            "Primary"
            "Secondary"
            "External"
          ];
        };
      };

      freeformType = toml.type;
    }
  );
in
{
  imports = with lib; [
    (mkRenamedOptionModule [ "services" "trust-dns" "enable" ] [ "services" "hickory-dns" "enable" ])
    (mkRenamedOptionModule [ "services" "trust-dns" "package" ] [ "services" "hickory-dns" "package" ])
    (mkRenamedOptionModule
      [ "services" "trust-dns" "settings" ]
      [ "services" "hickory-dns" "settings" ]
    )
    (mkRenamedOptionModule [ "services" "trust-dns" "quiet" ] [ "services" "hickory-dns" "quiet" ])
    (mkRenamedOptionModule [ "services" "trust-dns" "debug" ] [ "services" "hickory-dns" "debug" ])
  ];

  options = {
    services.hickory-dns = with lib; {
      enable = mkEnableOption "hickory-dns";

      package = mkPackageOption pkgs "hickory-dns" {
        extraDescription = ''
          ::: {.note}
          The package must provide `meta.mainProgram` which names the server binary; any other utilities (client, resolver) are not needed.
          :::
        '';
      };

      configFile = mkOption {
        default = toml.generate "hickory-dns.toml" (
          lib.mapAttrs (
            _: v:
            if builtins.isList v then
              map (v: if builtins.isAttrs v then lib.filterAttrs (_: v: v != null) v else v) v
            else
              v
          ) (lib.filterAttrsRecursive (_: v: v != null) cfg.settings)
        );

        defaultText = lib.literalExpression ''
          let toml = pkgs.formats.toml { }; in toml.generate "hickory-dns.toml" cfg.settings
        '';

        description = ''
          Path to an existing toml file to configure hickory-dns with.

          This can usually be left unspecified, in which case it will be
          generated from the values in `settings`.
          If manually specified, then the options in `settings` are ignored.
        '';

        type = types.path;
      };

      debug = mkOption {
        default = false;

        description = ''
          Log DEBUG, INFO, WARN and ERROR messages.
          This option is mutually exclusive with the `debug` option.
          If neither `quiet` nor `debug` are enabled, logging defaults to the INFO level.
        '';

        type = types.bool;
      };

      quiet = mkOption {
        default = false;

        description = ''
          Log ERROR level messages only.
          This option is mutually exclusive with the `debug` option.
          If neither `quiet` nor `debug` are enabled, logging defaults to the INFO level.
        '';

        type = types.bool;
      };

      settings = mkOption {
        description = ''
          Settings for hickory-dns. The options enumerated here are not exhaustive.
          Refer to upstream documentation for all available options:
          - [Example settings](https://github.com/hickory-dns/hickory-dns/blob/main/tests/test-data/test_configs/example.toml)
        '';

        type = types.submodule {
          options = {
            directory = mkOption {
              default = "/var/lib/hickory-dns";

              description = ''
                The directory in which hickory-dns should look for .zone files,
                whenever zones aren't specified by absolute path.
              '';

              type = types.str;
            };

            listen_addrs_ipv4 = mkOption {
              default = [ "0.0.0.0" ];

              description = ''
                List of ipv4 addresses on which to listen for DNS queries.
              '';

              type = types.listOf types.str;
            };

            listen_addrs_ipv6 = mkOption {
              default = lib.optional config.networking.enableIPv6 "::0";
              defaultText = literalExpression ''lib.optional config.networking.enableIPv6 "::0"'';

              description = ''
                List of ipv6 addresses on which to listen for DNS queries.
              '';

              type = types.listOf types.str;
            };

            listen_port = mkOption {
              default = 53;

              description = ''
                Port to listen on (applies to all listen addresses).
              '';

              type = types.port;
            };

            zones = mkOption {
              default = [ ];
              description = "List of zones to serve.";
              type = types.listOf (types.coercedTo types.str (zone: { inherit zone; }) zoneType);
            };
          };

          freeformType = toml.type;
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.hickory-dns = {
      after = [ "network.target" ];
      description = "hickory-dns Domain Name Server";

      serviceConfig = {
        AmbientCapabilities = [ "CAP_NET_BIND_SERVICE" ];
        CapabilityBoundingSet = [ "CAP_NET_BIND_SERVICE" ];
        DynamicUser = true;

        ExecStart =
          let
            flags = (lib.optional cfg.debug "--debug") ++ (lib.optional cfg.quiet "--quiet");
            flagsStr = builtins.concatStringsSep " " flags;
          in
          ''
            ${lib.getExe cfg.package} --config ${cfg.configFile} ${flagsStr}
          '';

        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateMounts = true;
        PrivateTmp = true;
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectProc = "invisible";
        ProtectSystem = "full";
        ReadWritePaths = [ cfg.settings.directory ];
        RemoveIPC = true;
        Restart = "on-failure";
        RestartSec = "10s";
        RestrictAddressFamilies = [ "AF_INET AF_INET6" ];
        RestrictNamespaces = true;
        RestrictSUIDSGID = true;
        StateDirectory = "hickory-dns";
        SystemCallArchitectures = "native";

        SystemCallFilter = [
          "@system-service"
          "~@privileged"
          "~@resources"
        ];

        Type = "simple";
      };

      unitConfig.Documentation = "https://hickory-dns.org/";
      wantedBy = [ "multi-user.target" ];
    };
  };

  meta.maintainers = with lib.maintainers; [ colinsane ];
}

{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.heisenbridge;

  pkg = config.services.heisenbridge.package;
  bin = "${pkg}/bin/heisenbridge";

  jsonType = (pkgs.formats.json { }).type;

  registrationFile = "/var/lib/heisenbridge/registration.yml";
  # JSON is a proper subset of YAML
  bridgeConfig = builtins.toFile "heisenbridge-registration.yml" (
    builtins.toJSON {
      id = "heisenbridge";
      namespaces = cfg.namespaces;
      # Don't specify as_token and hs_token
      rate_limited = false;
      sender_localpart = "heisenbridge";
      url = cfg.registrationUrl;
    }
  );
in
{
  options.services.heisenbridge = {
    enable = lib.mkEnableOption "the Matrix to IRC bridge";
    package = lib.mkPackageOption pkgs "heisenbridge" { };

    address = lib.mkOption {
      default = "127.0.0.1";
      description = "Address to listen on. IPv6 does not seem to be supported.";
      example = "0.0.0.0";
      type = lib.types.str;
    };

    debug = lib.mkOption {
      default = false;
      description = "More verbose logging. Recommended during initial setup.";
      type = lib.types.bool;
    };

    extraArgs = lib.mkOption {
      default = [ ];
      description = "Heisenbridge is configured over the command line. Append extra arguments here";
      type = lib.types.listOf lib.types.str;
    };

    homeserver = lib.mkOption {
      description = "The URL to the home server for client-server API calls";
      example = "http://localhost:8008";
      type = lib.types.str;
    };

    identd.enable = lib.mkEnableOption "identd service support";

    identd.port = lib.mkOption {
      default = 113;
      description = "identd listen port";
      type = lib.types.port;
    };

    namespaces = lib.mkOption {
      default = {
        aliases = [ ];
        rooms = [ ];

        users = [
          {
            exclusive = true;
            regex = "@irc_.*";
          }
        ];
      };

      description = "Configure the 'namespaces' section of the registration.yml for the bridge and the server";

      # TODO link to Matrix documentation of the format
      type = lib.types.submodule {
        freeformType = jsonType;
      };
    };

    owner = lib.mkOption {
      default = null;

      description = ''
        Set owner MXID otherwise first talking local user will claim the bridge
      '';

      example = "@admin:example.org";
      type = lib.types.nullOr lib.types.str;
    };

    port = lib.mkOption {
      default = 9898;
      description = "The port to listen on";
      type = lib.types.port;
    };

    registrationUrl = lib.mkOption {
      default = "http://${cfg.address}:${toString cfg.port}";
      defaultText = "http://$${cfg.address}:$${toString cfg.port}";

      description = ''
        The URL where the application service is listening for HS requests, from the Matrix HS perspective.#
        The default value assumes the bridge runs on the same host as the home server, in the same network.
      '';

      example = "https://matrix.example.org";
      type = lib.types.str;
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.heisenbridge = {
      before = [ "matrix-synapse.service" ]; # So the registration file can be used by Synapse
      description = "Matrix<->IRC bridge";

      preStart = ''
        umask 077
        set -e -u -o pipefail

        if ! [ -f "${registrationFile}" ]; then
          # Generate registration file if not present (actually, we only care about the tokens in it)
          ${bin} --generate --config ${registrationFile}
        fi

        # Overwrite the registration file with our generated one (the config may have changed since then),
        # but keep the tokens. Two step procedure to be failure safe
        ${pkgs.yq}/bin/yq --slurp \
          '.[0] + (.[1] | {as_token, hs_token})' \
          ${bridgeConfig} \
          ${registrationFile} \
          > ${registrationFile}.new
        mv -f ${registrationFile}.new ${registrationFile}

        # Grant Synapse access to the registration
        if ${pkgs.getent}/bin/getent group matrix-synapse > /dev/null; then
          chgrp -v matrix-synapse ${registrationFile}
          chmod -v g+r ${registrationFile}
        fi
      '';

      serviceConfig = rec {
        AmbientCapabilities = CapabilityBoundingSet;

        CapabilityBoundingSet = [
          "CAP_CHOWN"
        ]
        ++ lib.optional (
          cfg.port < 1024 || (cfg.identd.enable && cfg.identd.port < 1024)
        ) "CAP_NET_BIND_SERVICE";

        ExecStart = lib.concatStringsSep " " (
          [
            bin
            (if cfg.debug then "-vvv" else "-v")
            "--config"
            registrationFile
            "--listen-address"
            (lib.escapeShellArg cfg.address)
            "--listen-port"
            (toString cfg.port)
          ]
          ++ (lib.optionals (cfg.owner != null) [
            "--owner"
            (lib.escapeShellArg cfg.owner)
          ])
          ++ (lib.optionals cfg.identd.enable [
            "--identd"
            "--identd-port"
            (toString cfg.identd.port)
          ])
          ++ [
            (lib.escapeShellArg cfg.homeserver)
          ]
          ++ (map (lib.escapeShellArg) cfg.extraArgs)
        );

        Group = "heisenbridge";
        LockPersonality = true;
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateMounts = true;
        PrivateTmp = true;
        ProcSubset = "pid";
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
        RestrictAddressFamilies = "AF_INET AF_INET6";
        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        RuntimeDirectory = "heisenbridge";
        RuntimeDirectoryMode = "0700";
        StateDirectory = "heisenbridge";
        StateDirectoryMode = "0755";
        SystemCallArchitectures = "native";

        SystemCallFilter = [
          "@system-service"
          "~@privileged"
          "@chown"
        ];

        Type = "simple";
        UMask = "0077";
        # Hardening options
        User = "heisenbridge";
      };

      wantedBy = [ "multi-user.target" ];
    };

    users.groups.heisenbridge = { };

    users.users.heisenbridge = {
      description = "Service user for the Heisenbridge";
      group = "heisenbridge";
      isSystemUser = true;
    };
  };

  meta.maintainers = [ ];
}

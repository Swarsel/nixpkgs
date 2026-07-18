{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.adguardhome;
  settingsFormat = pkgs.formats.yaml { };

  args = lib.concatStringsSep " " (
    [
      "--no-check-update"
      "--pidfile /run/AdGuardHome/AdGuardHome.pid"
      "--work-dir /var/lib/AdGuardHome/"
      "--config /var/lib/AdGuardHome/AdGuardHome.yaml"
    ]
    ++ cfg.extraArgs
  );

  settings =
    if (cfg.settings != null) then
      cfg.settings
      // (
        if cfg.settings.schema_version < 23 then
          {
            bind_host = cfg.host;
            bind_port = cfg.port;
          }
        else
          {
            http.address = "${cfg.host}:${toString cfg.port}";
          }
      )
    else
      null;

  configFile = (settingsFormat.generate "AdGuardHome.yaml" settings).overrideAttrs (_: {
    checkPhase = "${cfg.package}/bin/AdGuardHome -c $out --check-config";
  });
in
{
  options.services.adguardhome = with lib.types; {
    enable = lib.mkEnableOption "AdGuard Home network-wide ad blocker";

    package = lib.mkOption {
      default = pkgs.adguardhome;
      defaultText = lib.literalExpression "pkgs.adguardhome";

      description = ''
        The package that runs adguardhome.
      '';

      type = package;
    };

    allowDHCP = lib.mkOption {
      default = settings.dhcp.enabled or false;
      defaultText = lib.literalExpression "config.services.adguardhome.settings.dhcp.enabled or false";

      description = ''
        Allows AdGuard Home to open raw sockets (`CAP_NET_RAW`), which is
        required for the integrated DHCP server.

        The default enables this conditionally if the declarative configuration
        enables the integrated DHCP server. Manually setting this option is only
        required for non-declarative setups.
      '';

      type = bool;
    };

    extraArgs = lib.mkOption {
      default = [ ];

      description = ''
        Extra command line parameters to be passed to the adguardhome binary.
      '';

      type = listOf str;
    };

    host = lib.mkOption {
      default = "0.0.0.0";

      description = ''
        Host address to bind HTTP server to.
      '';

      type = str;
    };

    mutableSettings = lib.mkOption {
      default = true;

      description = ''
        Allow changes made on the AdGuard Home web interface to persist between
        service restarts.
      '';

      type = bool;
    };

    openFirewall = lib.mkOption {
      default = false;

      description = ''
        Open ports in the firewall for the AdGuard Home web interface. Does not
        open the port needed to access the DNS resolver.
      '';

      type = bool;
    };

    port = lib.mkOption {
      default = 3000;

      description = ''
        Port to serve HTTP pages on.
      '';

      type = port;
    };

    settings = lib.mkOption {
      default = null;

      description = ''
        AdGuard Home configuration. Refer to
        <https://github.com/AdguardTeam/AdGuardHome/wiki/Configuration#configuration-file>
        for details on supported values.

        ::: {.note}
        On start and if {option}`mutableSettings` is `true`,
        these options are merged into the configuration file on start, taking
        precedence over configuration changes made on the web interface.

        Set this to `null` (default) for a non-declarative configuration without any
        Nix-supplied values.
        Declarative configurations are supplied with a default `schema_version`, and `http.address`.
        :::
      '';

      type = nullOr (submodule {
        options = {
          schema_version = lib.mkOption {
            default = cfg.package.schema_version;
            defaultText = lib.literalExpression "cfg.package.schema_version";

            description = ''
              Schema version for the configuration.
              Defaults to the `schema_version` supplied by `cfg.package`.
            '';

            type = int;
          };
        };

        freeformType = settingsFormat.type;
      });
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.settings != null -> !(lib.hasAttrByPath [ "bind_host" ] cfg.settings);
        message = "AdGuard option `settings.bind_host' has been superseded by `services.adguardhome.host'";
      }
      {
        assertion = cfg.settings != null -> !(lib.hasAttrByPath [ "bind_port" ] cfg.settings);
        message = "AdGuard option `settings.bind_port' has been superseded by `services.adguardhome.port'";
      }
      {
        assertion =
          settings != null -> cfg.mutableSettings || lib.hasAttrByPath [ "dns" "bootstrap_dns" ] settings;

        message = "AdGuard setting dns.bootstrap_dns needs to be configured for a minimal working configuration";
      }
      {
        assertion =
          settings != null
          ->
            cfg.mutableSettings
            || lib.hasAttrByPath [ "dns" "bootstrap_dns" ] settings && lib.isList settings.dns.bootstrap_dns;

        message = "AdGuard setting dns.bootstrap_dns needs to be a list";
      }
    ];

    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [ cfg.port ];

    systemd.services.adguardhome = {
      after = [ "network.target" ];
      description = "AdGuard Home: Network-level blocker";

      preStart =
        let
          installFresh = ''
            cp --force "${configFile}" "$STATE_DIRECTORY/AdGuardHome.yaml"
            chmod 600 "$STATE_DIRECTORY/AdGuardHome.yaml"
          '';
        in
        lib.optionalString (settings != null) (
          if cfg.mutableSettings then
            ''
              if [ -e "$STATE_DIRECTORY/AdGuardHome.yaml" ]; then
                # First run a schema_version update on the existing configuration
                # This ensures that both the new config and the existing one have the same schema_version
                # Note: --check-config has the side effect of modifying the file at rest!
                ${lib.getExe cfg.package} -c "$STATE_DIRECTORY/AdGuardHome.yaml" --check-config

                # Writing directly to AdGuardHome.yaml results in empty file
                ${lib.getExe pkgs.yaml-merge} "$STATE_DIRECTORY/AdGuardHome.yaml" "${configFile}" > "$STATE_DIRECTORY/AdGuardHome.yaml.tmp"
                mv "$STATE_DIRECTORY/AdGuardHome.yaml.tmp" "$STATE_DIRECTORY/AdGuardHome.yaml"
              else
                ${installFresh}
              fi
            ''
          else
            installFresh
        );

      serviceConfig = {
        AmbientCapabilities = [ "CAP_NET_BIND_SERVICE" ] ++ lib.optionals cfg.allowDHCP [ "CAP_NET_RAW" ];
        CapabilityBoundingSet = [ "CAP_NET_BIND_SERVICE" ] ++ lib.optionals cfg.allowDHCP [ "CAP_NET_RAW" ];
        DevicePolicy = "closed";
        DynamicUser = true;
        ExecStart = "${lib.getExe cfg.package} ${args}";
        LockPersonality = true;
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
        ProtectSystem = "strict";
        RemoveIPC = true;
        Restart = "always";
        RestartSec = 10;

        RestrictAddressFamilies = [
          "AF_NETLINK"
          "AF_INET"
          "AF_INET6"
        ]
        ++ lib.optionals cfg.allowDHCP [ "AF_PACKET" ];

        RestrictNamespaces = true;
        RestrictRealtime = true;
        RuntimeDirectory = "AdGuardHome";
        StateDirectory = "AdGuardHome";
        SystemCallArchitectures = "native";

        SystemCallFilter = [
          "@system-service"
          "~@privileged"
          "~@resources"
        ];

        UMask = "0077";
      };

      unitConfig = {
        StartLimitBurst = 10;
        StartLimitIntervalSec = 5;
      };

      wantedBy = [ "multi-user.target" ];
    };
  };
}

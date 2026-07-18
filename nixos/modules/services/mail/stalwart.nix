{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.stalwart;
  configFormat = pkgs.formats.toml { };
  configFile = configFormat.generate "stalwart.toml" cfg.settings;
  useLegacyStorage = lib.versionOlder cfg.stateVersion "24.11";
  pre2605 = lib.versionOlder cfg.stateVersion "26.05";
  stalwartIdentifier = if pre2605 then "stalwart-mail" else "stalwart";
  stalwartIdentifierText = ''if lib.versionOlder config.services.stalwart.stateVersion "26.05" then "stalwart-mail" else "stalwart"'';

  parsePorts =
    listeners:
    let
      parseAddresses = listeners: lib.flatten (lib.mapAttrsToList (name: value: value.bind) listeners);
      splitAddress = addr: lib.splitString ":" addr;
      extractPort = addr: lib.toInt (builtins.foldl' (a: b: b) "" (splitAddress addr));
    in
    map (address: extractPort address) (parseAddresses listeners);

in
{
  imports = [
    # since 0.12.0 (2025-05-26) release, upstream re-branded project to 'stalwart' due to inclusion of collaboration features (CalDAV, CardDAV, and WebDAV)
    #  https://github.com/stalwartlabs/stalwart/releases/tag/v0.12.0
    (lib.mkRenamedOptionModule [ "services" "stalwart-mail" ] [ "services" "stalwart" ])
  ];

  options.services.stalwart = {
    enable = lib.mkEnableOption "the all-in-one collaboration and mail server, Stalwart";
    package = lib.mkPackageOption pkgs "stalwart" { };

    credentials = lib.mkOption {
      default = { };

      description = ''
        Credentials envs used to configure Stalwart secrets.
        These secrets can be accessed in configuration values with
        the macros such as
        `%{file:/run/credentials/stalwart.service/VAR_NAME}%`.
      '';

      example = {
        user_admin_password = "/run/keys/stalwart_admin_password";
      };

      type = lib.types.attrsOf lib.types.str;
    };

    dataDir = lib.mkOption {
      default = "/var/lib/${stalwartIdentifier}";
      defaultText = lib.literalExpression "/var/lib/\${${stalwartIdentifierText}}";

      description = ''
        Data directory for stalwart
      '';

      type = lib.types.path;
    };

    group = lib.mkOption {
      default = stalwartIdentifier;
      defaultText = lib.literalExpression stalwartIdentifierText;

      description = ''
        Group ownership of service
      '';

      type = lib.types.str;
    };

    openFirewall = lib.mkOption {
      default = false;

      description = ''
        Whether to open TCP firewall ports, which are specified in
        {option}`services.stalwart.settings.server.listener` on all interfaces.
      '';

      type = lib.types.bool;
    };

    settings = lib.mkOption {
      inherit (configFormat) type;
      default = { };

      description = ''
        Configuration options for the Stalwart server.
        See <https://stalw.art/docs/category/configuration> for available options.

        By default, the module is configured to store everything locally.
      '';
    };

    stateVersion = lib.mkOption {
      description = ''
        The version of this module (=version of NixOS) when this module was first enabled on this particular machine, used to maintain compatibility with application data created on older versions of this module.

        See {option}`system.stateVersion` for details on the NixOS-global equivalent to this option.
      '';

      type = lib.types.str;
    };

    user = lib.mkOption {
      default = stalwartIdentifier;
      defaultText = lib.literalExpression stalwartIdentifierText;

      description = ''
        User ownership of service
      '';

      type = lib.types.str;
    };

  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion =
          !(
            (lib.hasAttrByPath [ "settings" "queue" ] cfg)
            && (builtins.any (lib.hasAttrByPath [
              "value"
              "next-hop"
            ]) (lib.attrsToList cfg.settings.queue))
          );

        message = ''
          Stalwart deprecated `next-hop` in favor of "virtual queues" `queue.strategy.route` \
          with v0.13.0 see [Outbound Strategy](https://stalw.art/docs/mta/outbound/strategy/#configuration) \
          and [release announcement](https://github.com/stalwartlabs/stalwart/blob/main/UPGRADING.md#upgrading-from-v012x-and-v011x-to-v013x).
        '';
      }
    ];

    # Make admin commands available in the shell
    environment.systemPackages = [ cfg.package ];

    networking.firewall =
      lib.mkIf (cfg.openFirewall && (builtins.hasAttr "listener" cfg.settings.server))
        {
          allowedTCPPorts = parsePorts cfg.settings.server.listener;
        };

    # Default config: all local
    services.stalwart.settings = {
      directory.internal.store = lib.mkDefault "db";
      directory.internal.type = lib.mkDefault "internal";

      resolver.public-suffix = lib.mkDefault [
        "file://${pkgs.publicsuffix-list}/share/publicsuffix/public_suffix_list.dat"
      ];

      resolver.type = lib.mkDefault "system";
      spam-filter.resource = lib.mkDefault "file://${cfg.package.spam-filter}/spam-filter.toml";
      storage.blob = lib.mkDefault (if useLegacyStorage then "fs" else "db");
      storage.data = lib.mkDefault "db";
      storage.directory = lib.mkDefault "internal";
      storage.fts = lib.mkDefault "db";
      storage.lookup = lib.mkDefault "db";

      store =
        if useLegacyStorage then
          {
            db.path = lib.mkDefault "${cfg.dataDir}/data/index.sqlite3";
            # structured data in SQLite, blobs on filesystem
            db.type = lib.mkDefault "sqlite";
            fs.path = lib.mkDefault "${cfg.dataDir}/data/blobs";
            fs.type = lib.mkDefault "fs";
          }
        else
          {
            db.compression = lib.mkDefault "lz4";
            db.path = lib.mkDefault "${cfg.dataDir}/db";
            # everything in RocksDB
            db.type = lib.mkDefault "rocksdb";
          };

      tracer =
        if pre2605 then
          {
            stdout = {
              enable = lib.mkDefault true;
              ansi = lib.mkDefault false; # no colour markers to journald
              level = lib.mkDefault "info";
              type = lib.mkDefault "stdout";
            };
          }
        else
          {
            journal = {
              enable = lib.mkDefault true;
              level = lib.mkDefault "info";
              type = lib.mkDefault "journal";
            };
          };

      webadmin =
        let
          hasHttpListener = builtins.any (listener: listener.protocol == "http") (
            lib.attrValues (cfg.settings.server.listener or { })
          );
        in
        {
          path = "/var/cache/${stalwartIdentifier}";
          resource = lib.mkIf hasHttpListener (lib.mkDefault "file://${cfg.package.webadmin}/webadmin.zip");
        };
    };

    systemd = {
      services.stalwart = {
        after = [
          "local-fs.target"
          "network.target"
        ];

        description = "Stalwart Server";

        serviceConfig = {
          # Bind standard privileged ports
          AmbientCapabilities = [ "CAP_NET_BIND_SERVICE" ];
          CacheDirectory = stalwartIdentifier;
          CapabilityBoundingSet = [ "CAP_NET_BIND_SERVICE" ];
          # Hardening
          DeviceAllow = [ "" ];

          ExecStart = [
            ""
            "${lib.getExe cfg.package} --config=${configFile}"
          ];

          ExecStartPre =
            if useLegacyStorage then
              ''
                ${lib.getExe' pkgs.coreutils "mkdir"} -p ${cfg.dataDir}/data/blobs
              ''
            else
              ''
                ${lib.getExe' pkgs.coreutils "mkdir"} -p ${cfg.dataDir}/db
              '';

          Group = cfg.group;
          KillMode = "process";
          KillSignal = "SIGINT";
          LimitNOFILE = 65536;
          LoadCredential = lib.mapAttrsToList (key: value: "${key}:${value}") cfg.credentials;
          LockPersonality = true;
          MemoryDenyWriteExecute = true;
          PrivateDevices = true;
          PrivateTmp = true;
          PrivateUsers = false; # incompatible with CAP_NET_BIND_SERVICE
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

          ReadWritePaths = [
            cfg.dataDir
          ];

          Restart = "on-failure";
          RestartSec = 5;

          RestrictAddressFamilies = [
            "AF_INET"
            "AF_INET6"
            "AF_UNIX"
          ];

          RestrictNamespaces = true;
          RestrictRealtime = true;
          RestrictSUIDSGID = true;
          StateDirectory = stalwartIdentifier;
          SyslogIdentifier = stalwartIdentifier;
          SystemCallArchitectures = "native";

          SystemCallFilter = [
            "@system-service"
            "~@privileged"
          ];

          # Upstream service config
          Type = "simple";
          UMask = "0077";
          # Upstream uses "stalwart" as the username since 0.12.0
          User = cfg.user;
        };

        unitConfig.ConditionPathExists = [
          "${configFile}"
        ];

        wantedBy = [ "multi-user.target" ];
      };
    };

    systemd.tmpfiles.rules = [
      "d '${cfg.dataDir}' - '${cfg.user}' '${cfg.group}' - -"
    ];

    # This service stores a potentially large amount of data.
    # Running it as a dynamic user would force chown to be run everytime the
    # service is restarted on a potentially large number of files.
    # That would cause unnecessary and unwanted delays.
    users = {
      groups = lib.mkIf (cfg.group == stalwartIdentifier) {
        ${cfg.group} = { };
      };

      users = lib.mkIf (cfg.user == stalwartIdentifier) {
        ${cfg.user} = {
          inherit (cfg) group;
          isSystemUser = true;
        };
      };
    };
  };

  meta = {
    maintainers = with lib.maintainers; [
      happysalada
      onny
      norpol
    ];
  };
}

{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.mchprs;
  settingsFormat = pkgs.formats.toml { };

  whitelistFile = pkgs.writeText "whitelist.json" (
    builtins.toJSON (
      lib.mapAttrsToList (n: v: {
        name = n;
        uuid = v;
      }) cfg.whitelist.list
    )
  );

  configToml =
    (removeAttrs cfg.settings [
      "address"
      "port"
    ])
    // {
      bind_address = cfg.settings.address + ":" + toString cfg.settings.port;
      whitelist = cfg.whitelist.enable;
    };

  configTomlFile = settingsFormat.generate "Config.toml" configToml;
in
{
  options = {
    services.mchprs = {
      enable = lib.mkEnableOption "MCHPRS, a Minecraft server";
      package = lib.mkPackageOption pkgs "mchprs" { };

      dataDir = lib.mkOption {
        default = "/var/lib/mchprs";

        description = ''
          Directory to store MCHPRS database and other state/data files.
        '';

        type = lib.types.path;
      };

      declarativeSettings = lib.mkOption {
        default = false;

        description = ''
          Whether to use a declarative configuration for MCHPRS.
        '';

        type = lib.types.bool;
      };

      declarativeWhitelist = lib.mkOption {
        default = false;

        description = ''
          Whether to use a declarative whitelist.
          The options {option}`services.mchprs.whitelist.list`
          will be applied if and only if set to `true`.
        '';

        type = lib.types.bool;
      };

      maxRuntime = lib.mkOption {
        default = "infinity";

        description = ''
          Automatically restart the server after
          {option}`services.mchprs.maxRuntime`.
          The {manpage}`systemd.time(7)` time span format is described here:
          <https://www.freedesktop.org/software/systemd/man/systemd.time.html#Parsing%20Time%20Spans>.
          If `null`, then the server is not restarted automatically.
        '';

        example = "7d";
        type = lib.types.str;
      };

      openFirewall = lib.mkOption {
        default = false;

        description = ''
          Whether to open ports in the firewall for the server.
          Only has effect when
          {option}`services.mchprs.declarativeSettings` is `true`.
        '';

        type = lib.types.bool;
      };

      settings = lib.mkOption {
        default = { };

        description = ''
          Configuration for MCHPRS via {file}`Config.toml`.
          See <https://github.com/MCHPR/MCHPRS/blob/master/README.md> for documentation.
        '';

        type = lib.types.submodule {
          options = {
            address = lib.mkOption {
              default = "0.0.0.0";

              description = ''
                Address for the server.
                Please use enclosing square brackets when using ipv6.
                Only has effect when
                {option}`services.mchprs.declarativeSettings` is `true`.
              '';

              type = lib.types.str;
            };

            auto_redpiler = lib.mkOption {
              default = true;

              description = ''
                Use redpiler automatically.
                Only has effect when
                {option}`services.mchprs.declarativeSettings` is `true`.
              '';

              type = lib.types.bool;
            };

            block_in_hitbox = lib.mkOption {
              default = true;

              description = ''
                Allow placing blocks inside of players
                (hitbox logic is simplified).
                Only has effect when
                {option}`services.mchprs.declarativeSettings` is `true`.
              '';

              type = lib.types.bool;
            };

            bungeecord = lib.mkOption {
              default = false;

              description = ''
                Enable compatibility with
                [BungeeCord](https://github.com/SpigotMC/BungeeCord).
                Only has effect when
                {option}`services.mchprs.declarativeSettings` is `true`.
              '';

              type = lib.types.bool;
            };

            chat_format = lib.mkOption {
              default = "<{username}> {message}";

              description = ''
                How to format chat message interpolating `username`
                and `message` with curly braces.
                Only has effect when
                {option}`services.mchprs.declarativeSettings` is `true`.
              '';

              type = lib.types.str;
            };

            max_players = lib.mkOption {
              default = 99999;

              description = ''
                Maximum number of simultaneous players.
                Only has effect when
                {option}`services.mchprs.declarativeSettings` is `true`.
              '';

              type = lib.types.ints.positive;
            };

            motd = lib.mkOption {
              default = "Minecraft High Performance Redstone Server";

              description = ''
                Message of the day.
                Only has effect when
                {option}`services.mchprs.declarativeSettings` is `true`.
              '';

              type = lib.types.str;
            };

            port = lib.mkOption {
              default = 25565;

              description = ''
                Port for the server.
                Only has effect when
                {option}`services.mchprs.declarativeSettings` is `true`.
              '';

              type = lib.types.port;
            };

            schemati = lib.mkOption {
              default = false;

              description = ''
                Mimic the verification and directory layout used by the
                Open Redstone Engineers
                [Schemati plugin](https://github.com/OpenRedstoneEngineers/Schemati).
                Only has effect when
                {option}`services.mchprs.declarativeSettings` is `true`.
              '';

              type = lib.types.bool;
            };

            view_distance = lib.mkOption {
              default = 8;

              description = ''
                Maximal distance (in chunks) between players and loaded chunks.
                Only has effect when
                {option}`services.mchprs.declarativeSettings` is `true`.
              '';

              type = lib.types.ints.positive;
            };
          };

          freeformType = settingsFormat.type;
        };
      };

      whitelist = {
        enable = lib.mkOption {
          default = false;

          description = ''
            Whether or not the whitelist (in {file}`whitelist.json`) shoud be enabled.
            Only has effect when {option}`services.mchprs.declarativeSettings` is `true`.
          '';

          type = lib.types.bool;
        };

        list = lib.mkOption {
          default = { };

          description = ''
            Whitelisted players, only has an effect when
            {option}`services.mchprs.declarativeWhitelist` is
            `true` and the whitelist is enabled
            via {option}`services.mchprs.whitelist.enable`.
            This is a mapping from Minecraft usernames to UUIDs.
            You can use <https://mcuuid.net/> to get a
            Minecraft UUID for a username.
          '';

          example = lib.literalExpression ''
            {
              username1 = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx";
              username2 = "yyyyyyyy-yyyy-yyyy-yyyy-yyyyyyyyyyyy";
            };
          '';

          type =
            let
              minecraftUUID =
                lib.types.strMatching "[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}"
                // {
                  description = "Minecraft UUID";
                };
            in
            lib.types.attrsOf minecraftUUID;
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {
    networking.firewall = lib.mkIf (cfg.declarativeSettings && cfg.openFirewall) {
      allowedTCPPorts = [ cfg.settings.port ];
      allowedUDPPorts = [ cfg.settings.port ];
    };

    systemd.services.mchprs = {
      after = [ "network.target" ];
      description = "MCHPRS Service";

      preStart =
        (
          if cfg.declarativeSettings then
            ''
              if [ -e .declarativeSettings ]; then

                # Settings were declarative before, no need to back up anything
                cp -f ${configTomlFile} Config.toml

              else

                # Declarative settings for the first time, backup stateful files
                cp -b --suffix=.stateful ${configTomlFile} Config.toml

                echo "Autogenerated file that implies that this server configuration is managed declaratively by NixOS" \
                  > .declarativeSettings

              fi
            ''
          else
            ''
              if [ -e .declarativeSettings ]; then
                rm .declarativeSettings
              fi
            ''
        )
        + (
          if cfg.declarativeWhitelist then
            ''
              if [ -e .declarativeWhitelist ]; then

                # Whitelist was declarative before, no need to back up anything
                ln -sf ${whitelistFile} whitelist.json

              else

                # Declarative whitelist for the first time, backup stateful files
                ln -sb --suffix=.stateful ${whitelistFile} whitelist.json

                echo "Autogenerated file that implies that this server's whitelist is managed declaratively by NixOS" \
                  > .declarativeWhitelist

              fi
            ''
          else
            ''
              if [ -e .declarativeWhitelist ]; then
                rm .declarativeWhitelist
              fi
            ''
        );

      serviceConfig = {
        # Hardening
        CapabilityBoundingSet = [ "" ];
        DeviceAllow = [ "" ];
        ExecStart = "${lib.getExe cfg.package}";
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        PrivateDevices = true;
        PrivateTmp = true;
        PrivateUsers = true;
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectProc = "invisible";
        Restart = "always";

        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
        ];

        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        RuntimeMaxSec = cfg.maxRuntime;
        StandardError = "journal";
        StandardOutput = "journal";
        SystemCallArchitectures = "native";
        UMask = "0077";
        User = "mchprs";
        WorkingDirectory = cfg.dataDir;
      };

      wantedBy = [ "multi-user.target" ];
    };

    users.groups.mchprs = { };

    users.users.mchprs = {
      createHome = true;
      description = "MCHPRS service user";
      group = "mchprs";
      home = cfg.dataDir;
      isSystemUser = true;
    };
  };

  meta.maintainers = with lib.maintainers; [ gdd ];
}

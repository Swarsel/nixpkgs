{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.syncplay;

  cmdArgs = [
    "--port"
    cfg.port
  ]
  ++ optionals (cfg.isolateRooms) [ "--isolate-rooms" ]
  ++ optionals (!cfg.ready) [ "--disable-ready" ]
  ++ optionals (!cfg.chat) [ "--disable-chat" ]
  ++ optionals (cfg.salt != null) [
    "--salt"
    cfg.salt
  ]
  ++ optionals (cfg.motdFile != null) [
    "--motd-file"
    cfg.motdFile
  ]
  ++ optionals (cfg.roomsDBFile != null) [
    "--rooms-db-file"
    cfg.roomsDBFile
  ]
  ++ optionals (cfg.permanentRoomsFile != null) [
    "--permanent-rooms-file"
    cfg.permanentRoomsFile
  ]
  ++ [
    "--max-chat-message-length"
    cfg.maxChatMessageLength
  ]
  ++ [
    "--max-username-length"
    cfg.maxUsernameLength
  ]
  ++ optionals (cfg.statsDBFile != null) [
    "--stats-db-file"
    cfg.statsDBFile
  ]
  ++ optionals (cfg.certDir != null) [
    "--tls"
    cfg.certDir
  ]
  ++ optionals cfg.ipv4Only [ "--ipv4-only" ]
  ++ optionals cfg.ipv6Only [ "--ipv6-only" ]
  ++ optionals (cfg.interfaceIpv4 != "") [
    "--interface-ipv4"
    cfg.interfaceIpv4
  ]
  ++ optionals (cfg.interfaceIpv6 != "") [
    "--interface-ipv6"
    cfg.interfaceIpv6
  ]
  ++ cfg.extraArgs;

  useACMEHostDir = optionalString (
    cfg.useACMEHost != null
  ) config.security.acme.certs.${cfg.useACMEHost}.directory;
in
{
  imports = [
    (mkRemovedOptionModule [ "services" "syncplay" "user" ]
      "The syncplay service now uses DynamicUser, override the systemd unit settings if you need the old functionality."
    )
    (mkRemovedOptionModule [ "services" "syncplay" "group" ]
      "The syncplay service now uses DynamicUser, override the systemd unit settings if you need the old functionality."
    )
  ];

  options = {
    services.syncplay = {
      enable = mkOption {
        default = false;

        description = ''
          If enabled, start the Syncplay server.
        '';

        type = types.bool;
      };

      package = mkPackageOption pkgs "syncplay-nogui" { };

      certDir = mkOption {
        default = null;

        description = ''
          TLS certificates directory to use for encryption. See
          <https://github.com/Syncplay/syncplay/wiki/TLS-support>.
        '';

        type = types.nullOr types.path;
      };

      chat = mkOption {
        default = true;

        description = ''
          Chat with users in the same room.
        '';

        type = types.bool;
      };

      extraArgs = mkOption {
        default = [ ];

        description = ''
          Additional arguments to be passed to the service.
        '';

        type = types.listOf types.str;
      };

      interfaceIpv4 = mkOption {
        default = "";

        description = ''
          The IP address to bind to for IPv4. Leaving it empty defaults to using all.
        '';

        type = types.str;
      };

      interfaceIpv6 = mkOption {
        default = "";

        description = ''
          The IP address to bind to for IPv6. Leaving it empty defaults to using all.
        '';

        type = types.str;
      };

      ipv4Only = mkOption {
        default = false;

        description = ''
          Listen only on IPv4 when strting the server.
        '';

        type = types.bool;
      };

      ipv6Only = mkOption {
        default = false;

        description = ''
          Listen only on IPv6 when strting the server.
        '';

        type = types.bool;
      };

      isolateRooms = mkOption {
        default = false;

        description = ''
          Enable room isolation.
        '';

        type = types.bool;
      };

      maxChatMessageLength = mkOption {
        default = 150;

        description = ''
          Maximum number of characters in a chat message.
        '';

        type = types.ints.unsigned;
      };

      maxUsernameLength = mkOption {
        default = 16;

        description = ''
          Maximum number of characters in a username.
        '';

        type = types.ints.unsigned;
      };

      motd = mkOption {
        default = null;

        description = ''
          Text to display when users join. The motd will be readable in the nix store
          and the processlist.  If this is not intended use `motdFile` instead.
          Will be overriden by {option}`services.syncplay.motdFile`.
        '';

        type = types.nullOr types.str;
      };

      motdFile = mkOption {
        default = if cfg.motd != null then (builtins.toFile "motd" cfg.motd) else null;
        defaultText = literalExpression ''if services.syncplay.motd != null then (builtins.toFile "motd" services.syncplay.motd) else null'';

        description = ''
          Path to text to display when users join.
          Will override {option}`services.syncplay.motd`.
        '';

        type = types.nullOr types.str;
      };

      passwordFile = mkOption {
        default = null;

        description = ''
          Path to the file that contains the server password. If
          `null`, the server doesn't require a password.
        '';

        type = types.nullOr types.path;
      };

      permanentRooms = mkOption {
        default = [ ];

        description = ''
          List of rooms that will be listed even if the room is empty.
          Will be overriden by {option}`services.syncplay.permanentRoomsFile`.
        '';

        type = types.listOf types.str;
      };

      permanentRoomsFile = mkOption {
        default =
          if cfg.permanentRooms != [ ] then
            (builtins.toFile "perm" (builtins.concatStringsSep "\n" cfg.permanentRooms))
          else
            null;

        defaultText = literalExpression ''if services.syncplay.permanentRooms != [ ] then (builtins.toFile "perm" (builtins.concatStringsSep "\n" services.syncplay.permanentRooms)) else null'';

        description = ''
          File with list of rooms that will be listed even if the room is empty,
          newline delimited.
          Will override {option}`services.syncplay.permanentRooms`.
        '';

        type = types.nullOr types.str;
      };

      port = mkOption {
        default = 8999;

        description = ''
          TCP port to bind to.
        '';

        type = types.port;
      };

      ready = mkOption {
        default = true;

        description = ''
          Check readiness of users.
        '';

        type = types.bool;
      };

      roomsDBFile = mkOption {
        default = null;

        description = ''
          Path to SQLite database file to store room states.
          Relative to the working directory provided by systemd.
        '';

        example = "rooms.db";
        type = types.nullOr types.str;
      };

      salt = mkOption {
        default = null;

        description = ''
          Salt to allow room operator passwords generated by this server
          instance to still work when the server is restarted.  The salt will be
          readable in the nix store and the processlist.  If this is not
          intended use `saltFile` instead.  Mutually exclusive with
          {option}`services.syncplay.saltFile`.
        '';

        type = types.nullOr types.str;
      };

      saltFile = mkOption {
        default = null;

        description = ''
          Path to the file that contains the server salt.  This allows room
          operator passwords generated by this server instance to still work
          when the server is restarted.  `null`, the server doesn't load the
          salt from a file.  Mutually exclusive with
          {option}`services.syncplay.salt`.
        '';

        type = types.nullOr types.path;
      };

      statsDBFile = mkOption {
        default = null;

        description = ''
          Path to SQLite database file to store stats.
          Relative to the working directory provided by systemd.
        '';

        example = "stats.db";
        type = types.nullOr types.str;
      };

      useACMEHost = mkOption {
        default = null;

        description = ''
          If set, use NixOS-generated ACME certificate with the specified name for TLS.

          Note that it requires {option}`security.acme` to be setup, e.g., credentials provided if using DNS-01 validation.
        '';

        example = "syncplay.example.com";
        type = types.nullOr types.str;
      };
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.salt == null || cfg.saltFile == null;
        message = "services.syncplay.salt and services.syncplay.saltFile are mutually exclusive.";
      }
      {
        assertion = cfg.certDir == null || cfg.useACMEHost == null;
        message = "services.syncplay.certDir and services.syncplay.useACMEHost are mutually exclusive.";
      }
      {
        assertion = !cfg.ipv4Only || !cfg.ipv6Only;
        message = "services.syncplay.ipv4Only and services.syncplay.ipv6Only are mutually exclusive.";
      }
    ];

    networking.firewall.allowedTCPPorts = [ cfg.port ];

    security.acme.certs = mkIf (cfg.useACMEHost != null) {
      "${cfg.useACMEHost}".reloadServices = [ "syncplay.service" ];
    };

    systemd.services.syncplay = {
      after = [ "network-online.target" ];
      description = "Syncplay Service";

      script = ''
        ${optionalString (cfg.passwordFile != null) ''
          export SYNCPLAY_PASSWORD=$(cat "''${CREDENTIALS_DIRECTORY}/password")
        ''}
        ${optionalString (cfg.saltFile != null) ''
          export SYNCPLAY_SALT=$(cat "''${CREDENTIALS_DIRECTORY}/salt")
        ''}
        exec ${cfg.package}/bin/syncplay-server ${escapeShellArgs cmdArgs} ${
          optionalString (cfg.useACMEHost != null) "--tls $CREDENTIALS_DIRECTORY"
        }
      '';

      serviceConfig = {
        DynamicUser = true;

        LoadCredential =
          optional (cfg.passwordFile != null) "password:${cfg.passwordFile}"
          ++ optional (cfg.saltFile != null) "salt:${cfg.saltFile}"
          ++ optionals (cfg.useACMEHost != null) [
            "cert.pem:${useACMEHostDir}/cert.pem"
            "privkey.pem:${useACMEHostDir}/key.pem"
            "chain.pem:${useACMEHostDir}/chain.pem"
          ];

        StateDirectory = "syncplay";
        WorkingDirectory = "%S/syncplay";
      };

      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
    };

    warnings =
      optional (cfg.interfaceIpv4 != "" && cfg.ipv6Only)
        "You have specified services.syncplay.interfaceIpv4 but IPv4 is disabled by services.syncplay.ipv6Only."
      ++
        optional (cfg.interfaceIpv6 != "" && cfg.ipv4Only)
          "You have specified services.syncplay.interfaceIpv6 but IPv6 is disabled by services.syncplay.ipv4Only.";
  };
}

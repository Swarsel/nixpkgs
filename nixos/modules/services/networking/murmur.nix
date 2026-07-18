{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.murmur;
  acmeHostDir = config.security.acme.certs."${cfg.tls.useACMEHost}".directory;

  forking = cfg.logToFile;
  configFile = pkgs.writeText "murmurd.ini" ''
    database=${cfg.stateDir}/murmur.sqlite
    dbDriver=QSQLITE

    autobanAttempts=${toString cfg.autobanAttempts}
    autobanTimeframe=${toString cfg.autobanTimeframe}
    autobanTime=${toString cfg.autobanTime}

    logfile=${lib.optionalString cfg.logToFile "/var/log/murmur/murmurd.log"}
    ${lib.optionalString forking "pidfile=/run/murmur/murmurd.pid"}

    welcometext="${cfg.welcometext}"
    port=${toString cfg.port}

    ${lib.optionalString (cfg.hostName != "") "host=${cfg.hostName}"}
    ${lib.optionalString (cfg.password != "") "serverpassword=${cfg.password}"}

    bandwidth=${toString cfg.bandwidth}
    users=${toString cfg.users}

    textmessagelength=${toString cfg.textMsgLength}
    imagemessagelength=${toString cfg.imgMsgLength}
    allowhtml=${lib.boolToString cfg.allowHtml}
    logdays=${toString cfg.logDays}
    bonjour=${lib.boolToString cfg.bonjour}
    sendversion=${lib.boolToString cfg.sendVersion}

    ${lib.optionalString (cfg.registerName != "") "registerName=${cfg.registerName}"}
    ${lib.optionalString (cfg.registerPassword != "") "registerPassword=${cfg.registerPassword}"}
    ${lib.optionalString (cfg.registerUrl != "") "registerUrl=${cfg.registerUrl}"}
    ${lib.optionalString (cfg.registerHostname != "") "registerHostname=${cfg.registerHostname}"}

    certrequired=${lib.boolToString cfg.clientCertRequired}
    ${lib.optionalString (cfg.tls.certPath != null) "sslCert=${cfg.tls.certPath}"}
    ${lib.optionalString (cfg.tls.keyPath != null) "sslKey=${cfg.tls.keyPath}"}
    ${lib.optionalString (cfg.tls.caPath != null) "sslCA=${cfg.tls.caPath}"}

    ${lib.optionalString (cfg.dbus != null) "dbus=${cfg.dbus}"}

    ${cfg.extraConfig}
  '';
in
{

  imports = [
    (lib.mkRemovedOptionModule [
      "services"
      "murmur"
      "logFile"
    ] "This option has been superseded by services.murmur.logToFile")
    (lib.mkRenamedOptionModule [ "services" "murmur" "sslCa" ] [ "services" "murmur" "tls" "caPath" ])
    (lib.mkRenamedOptionModule [ "services" "murmur" "sslKey" ] [ "services" "murmur" "tls" "keyPath" ])
    (lib.mkRenamedOptionModule
      [ "services" "murmur" "sslCert" ]
      [ "services" "murmur" "tls" "certPath" ]
    )
  ];

  options = {
    services.murmur = {
      enable = lib.mkEnableOption "Mumble server";
      package = lib.mkPackageOption pkgs "murmur" { };

      allowHtml = lib.mkOption {
        default = true;

        description = ''
          Allow HTML in client messages, comments, and channel
          descriptions.
        '';

        type = lib.types.bool;
      };

      autobanAttempts = lib.mkOption {
        default = 10;

        description = ''
          Number of attempts a client is allowed to make in
          `autobanTimeframe` seconds, before being
          banned for `autobanTime`.
        '';

        type = lib.types.int;
      };

      autobanTime = lib.mkOption {
        default = 300;
        description = "The amount of time an IP ban lasts (in seconds).";
        type = lib.types.int;
      };

      autobanTimeframe = lib.mkOption {
        default = 120;

        description = ''
          Timeframe in which a client can connect without being banned
          for repeated attempts (in seconds).
        '';

        type = lib.types.int;
      };

      bandwidth = lib.mkOption {
        default = 72000;

        description = ''
          Maximum bandwidth (in bits per second) that clients may send
          speech at.
        '';

        type = lib.types.int;
      };

      bonjour = lib.mkEnableOption "Bonjour auto-discovery, which allows clients over your LAN to automatically discover Mumble servers";
      clientCertRequired = lib.mkEnableOption "requiring clients to authenticate via certificates";

      dbus = lib.mkOption {
        default = null;
        description = "Enable D-Bus remote control. Set to the bus you want Murmur to connect to.";

        type = lib.types.enum [
          null
          "session"
          "system"
        ];
      };

      environmentFile = lib.mkOption {
        default = null;

        description = ''
          Environment file as defined in {manpage}`systemd.exec(5)`.

          Secrets may be passed to the service without adding them to the world-readable
          Nix store, by specifying placeholder variables as the option value in Nix and
          setting these variables accordingly in the environment file.

          ```
            # snippet of murmur-related config
            services.murmur.password = "$MURMURD_PASSWORD";
          ```

          ```
            # content of the environment file
            MURMURD_PASSWORD=verysecretpassword
          ```

          Note that this file needs to be available on the host on which
          `murmur` is running.
        '';

        example = lib.literalExpression ''"''${config.services.murmur.stateDir}/murmurd.env"'';
        type = lib.types.nullOr lib.types.path;
      };

      extraConfig = lib.mkOption {
        default = "";
        description = "Extra configuration to put into murmur.ini.";
        type = lib.types.lines;
      };

      group = lib.mkOption {
        default = "murmur";

        description = ''
          The name of an existing group to use to run the service.
          If not specified, the default group will be created.
        '';

        type = lib.types.str;
      };

      hostName = lib.mkOption {
        default = "";
        description = "Host to bind to. Defaults binding on all addresses.";
        type = lib.types.str;
      };

      imgMsgLength = lib.mkOption {
        default = 131072;
        description = "Max length of image messages. Set 0 for no limit.";
        type = lib.types.int;
      };

      logDays = lib.mkOption {
        default = 31;

        description = ''
          How long to store RPC logs for in the database. Set 0 to
          keep logs forever, or -1 to disable DB logging.
        '';

        type = lib.types.int;
      };

      logToFile = lib.mkEnableOption "logging to a file instead of journald, which is stored in /var/log/murmur";
      openFirewall = lib.mkEnableOption "opening ports in the firewall for the Mumble server";

      password = lib.mkOption {
        default = "";
        description = "Required password to join server, if specified.";
        type = lib.types.str;
      };

      port = lib.mkOption {
        default = 64738;
        description = "Ports to bind to (UDP and TCP).";
        type = lib.types.port;
      };

      registerHostname = lib.mkOption {
        default = "";

        description = ''
          DNS hostname where your server can be reached. This is only
          needed if you want your server to be accessed by its
          hostname and not IP - but the name *must* resolve on the
          internet properly.
        '';

        type = lib.types.str;
      };

      registerName = lib.mkOption {
        default = "";

        description = ''
          Public server registration name, and also the name of the
          Root channel. Even if you don't publicly register your
          server, you probably still want to set this.
        '';

        type = lib.types.str;
      };

      registerPassword = lib.mkOption {
        default = "";

        description = ''
          Public server registry password, used authenticate your
          server to the registry to prevent impersonation; required for
          subsequent registry updates.
        '';

        type = lib.types.str;
      };

      registerUrl = lib.mkOption {
        default = "";
        description = "URL website for your server.";
        type = lib.types.str;
      };

      sendVersion = lib.mkOption {
        default = true;
        description = "Send Murmur version in UDP response.";
        type = lib.types.bool;
      };

      stateDir = lib.mkOption {
        default = "/var/lib/murmur";

        description = ''
          Directory to store data for the server.
        '';

        type = lib.types.path;
      };

      textMsgLength = lib.mkOption {
        default = 5000;
        description = "Max length of text messages. Set 0 for no limit.";
        type = lib.types.int;
      };

      tls = {
        caPath = lib.mkOption {
          default = if (cfg.tls.useACMEHost != null) then "${acmeHostDir}/chain.pem" else null;
          defaultText = lib.literalMD "If {option}`services.murmur.tls.useACMEHost` is set, defaults to what's provided by the ACME module.";
          description = "Path to your TLS CA certificate.";
          type = lib.types.nullOr lib.types.path;
        };

        certPath = lib.mkOption {
          default = if (cfg.tls.useACMEHost != null) then "${acmeHostDir}/cert.pem" else null;
          defaultText = lib.literalMD "If {option}`services.murmur.tls.useACMEHost` is set, defaults to what's provided by the ACME module.";
          description = "Path to your TLS certificate.";
          type = lib.types.nullOr lib.types.path;
        };

        keyPath = lib.mkOption {
          default = if (cfg.tls.useACMEHost != null) then "${acmeHostDir}/key.pem" else null;
          defaultText = lib.literalMD "If {option}`services.murmur.tls.useACMEHost` is set, defaults to what's provided by the ACME module.";
          description = "Path to your TLS key.";
          type = lib.types.nullOr lib.types.path;
        };

        useACMEHost = lib.mkOption {
          default = null;

          description = ''
            Host of an existing Let's Encrypt certificate to use for TLS.
            Make sure that the certificate directory is readable by the
            `murmur` user or group. *Note that this option does not
            create any certificates and it doesn't add subdomains to
            existing ones – you will need to create them manually using
            {option}`security.acme.certs`.*
          '';

          example = "mumble.example.com";
          type = lib.types.nullOr lib.types.str;
        };
      };

      user = lib.mkOption {
        default = "murmur";

        description = ''
          The name of an existing user to use to run the service.
          If not specified, the default user will be created.
        '';

        type = lib.types.str;
      };

      users = lib.mkOption {
        default = 100;
        description = "Maximum number of concurrent clients allowed.";
        type = lib.types.int;
      };

      welcometext = lib.mkOption {
        default = "";
        description = "Welcome message for connected clients.";
        type = lib.types.str;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    networking.firewall = lib.mkIf cfg.openFirewall {
      allowedTCPPorts = [ cfg.port ];
      allowedUDPPorts = [ cfg.port ];
    };

    security.acme.certs = lib.mkIf (cfg.tls.useACMEHost != null) {
      "${cfg.tls.useACMEHost}".reloadServices = [ "murmur.service" ];
    };

    security.apparmor.policies."bin.mumble-server".profile = ''
      abi <abi/4.0>,
      include <tunables/global>

      profile ${cfg.package}/bin/{mumble-server,.mumble-server-wrapped} {
        include <abstractions/base>
        include <abstractions/nameservice>
        include <abstractions/ssl_certs>
        include "${pkgs.apparmorRulesFromClosure { name = "mumble-server"; } cfg.package}"
        ${cfg.package}/bin/.mumble-server-wrapped pix,

        ${config.environment.etc."os-release".source} r,
        ${config.environment.etc."lsb-release".source} r,
        owner ${cfg.stateDir}/murmur.sqlite rwk,
        owner ${cfg.stateDir}/murmur.sqlite-journal rw,
        owner ${cfg.stateDir}/ r,
        /run/murmur/murmurd.pid r,
        /run/murmur/murmurd.ini r,
        ${configFile} r,
        ${lib.optionalString cfg.logToFile ''
          /var/log/murmur/murmurd.log rw,
        ''}
        ${lib.optionalString (cfg.tls.certPath != null) ''
          ${cfg.tls.certPath} r,
        ''}
        ${lib.optionalString (cfg.tls.keyPath != null) ''
          ${cfg.tls.keyPath} r,
        ''}
        ${lib.optionalString (cfg.tls.caPath != null) ''
          ${cfg.tls.caPath} r,
        ''}
        ${lib.optionalString (cfg.dbus != null) ''
          dbus bus=${cfg.dbus},
        ''}
        include if exists <local/bin.mumble-server>
      }
    '';

    # currently not included in upstream package, addition requested at
    # https://github.com/mumble-voip/mumble/issues/6078
    services.dbus.packages = lib.mkIf (cfg.dbus == "system") [
      (pkgs.writeTextFile {
        destination = "/share/dbus-1/system.d/murmur.conf";
        name = "murmur-dbus-policy";

        text = ''
          <!DOCTYPE busconfig PUBLIC
            "-//freedesktop//DTD D-BUS Bus Configuration 1.0//EN"
            "http://www.freedesktop.org/standards/dbus/1.0/busconfig.dtd">
          <busconfig>
            <policy user="${cfg.user}">
              <allow own="net.sourceforge.mumble.murmur"/>
            </policy>

            <policy context="default">
              <allow send_destination="net.sourceforge.mumble.murmur"/>
              <allow receive_sender="net.sourceforge.mumble.murmur"/>
            </policy>
          </busconfig>
        '';
      })
    ];

    systemd.services.murmur = {
      after = [
        "network.target"
      ]
      ++ lib.optional (cfg.tls.useACMEHost != null) "acme-${cfg.tls.useACMEHost}.service";

      description = "Murmur Chat Service";

      preStart = ''
        ${pkgs.envsubst}/bin/envsubst \
          -o /run/murmur/murmurd.ini \
          -i ${configFile}
      '';

      serviceConfig = {
        # service hardening
        AmbientCapabilities = "CAP_NET_BIND_SERVICE";
        CapabilityBoundingSet = "CAP_NET_BIND_SERVICE";
        EnvironmentFile = lib.mkIf (cfg.environmentFile != null) cfg.environmentFile;
        ExecStart = "${cfg.package}/bin/mumble-server -ini /run/murmur/murmurd.ini";
        Group = cfg.group;
        LockPersonality = true;
        LogsDirectory = lib.mkIf cfg.logToFile "murmur";
        LogsDirectoryMode = "0750";
        MemoryDenyWriteExecute = true;
        MountAPIVFS = true;
        NoNewPrivileges = true;
        PIDFile = lib.mkIf forking "/run/murmur/murmurd.pid";
        PrivateDevices = true;
        PrivateMounts = true;
        PrivateTmp = true;
        PrivateUsers = true;
        ProtectClock = true;
        ProtectControlGroups = "strict";
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectProc = "invisible";
        ProtectSystem = "strict";

        ReadWritePaths = [
          cfg.stateDir
        ];

        Restart = "always";

        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
        ];

        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        RuntimeDirectory = "murmur";
        RuntimeDirectoryMode = "0700";
        SystemCallArchitectures = "native";
        SystemCallFilter = "@system-service";
        # murmurd doesn't fork when logging to the console.
        Type = if forking then "forking" else "simple";
        UMask = 27;
        User = cfg.user;
      };

      wantedBy = [ "multi-user.target" ];
      wants = lib.mkIf (cfg.tls.useACMEHost != null) [ "acme-${cfg.tls.useACMEHost}.service" ];
    };

    users.groups.murmur = lib.mkIf (cfg.group == "murmur") {
      gid = config.ids.gids.murmur;
    };

    users.users.murmur = lib.mkIf (cfg.user == "murmur") {
      createHome = true;
      description = "Murmur Service user";
      group = cfg.group;
      home = cfg.stateDir;
      uid = config.ids.uids.murmur;
    };
  };

  meta.maintainers = with lib.maintainers; [ felixsinger ];
}

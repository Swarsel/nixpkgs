{
  config,
  lib,
  pkgs,
  utils,
  ...
}:
let
  cfg = config.services.amule;

  settingsFormat = pkgs.formats.ini { };

  inherit (lib)
    mkOption
    mkEnableOption
    mkPackageOption
    types
    optionalAttrs
    mkIf
    mkMerge
    literalExpression
    optionalString
    optionals
    getExe
    ;

  settingsOptions = {
    ExternalConnect = {
      AcceptExternalConnections = mkOption {
        default = 1;
        description = "Whether to accept external connections, if disabled amuled refuses to start";
        internal = true;

        type = types.enum [
          0
          1
        ];
      };

      ECPassword = mkOption {
        default = "";

        description = ''
          MD5 hash of the password, obtainaible with `echo "<password>" | md5sum | cut -d ' ' -f 1`
        '';

        type = types.str;
      };

      ECPort = mkOption {
        default = 4712;
        description = "TCP port for external connections, like remote control via amule-gui";
        type = types.port;
      };
    };

    WebServer = {
      Enabled = lib.mkOption {
        default = 0;
        description = "Set to 1 to enable the web server";

        type = types.enum [
          0
          1
        ];
      };

      Password = mkOption {
        default = "";

        description = ''
          MD5 hash of the password, obtainaible with `echo "<password>" | md5sum | cut -d ' ' -f 1`
        '';

        type = types.str;
      };

      Port = mkOption {
        default = 4711;
        description = "Web server port";
        type = types.port;
      };
    };

    eMule = {
      IncomingDir = mkOption {
        default = "${cfg.dataDir}/Incoming";
        defaultText = literalExpression "\${config.services.amule.dataDir}/Incoming";

        description = ''
          Directory where aMule moves completed downloads.
          Files in this directory are automatically shared.
          Ensure the aMule service has write permissions
        '';

        type = types.path;
      };

      OSDirectory = mkOption {
        default = cfg.dataDir;
        defaultText = literalExpression "\${config.services.amule.dataDir}";
        description = "On-disk state directory, probably you don't want to change this";
        internal = true;
        type = types.path;
      };

      Port = mkOption {
        default = 4662;

        description = ''
          TCP port for eD2k connections.
          Required for connecting to servers and achieving a High ID.
        '';

        type = types.port;
      };

      TempDir = mkOption {
        default = "${cfg.dataDir}/Temp";
        defaultText = literalExpression "\${config.services.amule.dataDir}/Temp";

        description = ''
          Directory where aMule stores incomplete downloads (.part/.part.met files).
        '';

        type = types.path;
      };

      UDPPort = mkOption {
        default = 4672;

        description = ''
          UDP port for eD2k traffic (searches, source exchange) and all Kad network communication.
          Essential for a High ID on both networks and proper Kad functioning.
        '';

        type = types.port;
      };
    };
  };

  webServerEnabled = cfg.settings.WebServer.Enabled == 1;
in
{
  options.services.amule = {
    enable = mkEnableOption "aMule daemon";
    package = mkPackageOption pkgs "amule-daemon" { };

    ExternalConnectPasswordFile = mkOption {
      default = null;

      description = ''
        File containing the password for connecting with amule-gui,
        set this only if you didn't set `settings.ExternalConnect.ECPassword`
      '';

      type = types.nullOr types.path;
    };

    WebServerPasswordFile = mkOption {
      default = null;

      description = ''
        File containing the password for connecting to the web server,
        set this only if you didn't set `settings.ExternalConnect.ECPassword`
      '';

      type = types.nullOr types.path;
    };

    amuleWebPackage = mkPackageOption pkgs "amule-web" { };

    dataDir = mkOption {
      default = "/var/lib/amuled";
      description = "Directory holding configuration and by default also incoming and temporary files";
      type = types.path;
    };

    extraArgs = mkOption {
      default = [ ];
      description = "Additional passed arguments";
      type = types.listOf types.str;
    };

    group = mkOption {
      default = "amule";
      description = "Group under which amule runs";
      type = types.str;
    };

    openExternalConnectPort = mkEnableOption "open the external connect port";
    openPeerPorts = mkEnableOption "open the peer port(s) in the firewall";
    openWebServerPort = mkEnableOption "open the web server port";

    settings = mkOption {
      default = { };

      description = ''
        Free form attribute set for aMule settings.
        The final configuration file is generated merging the default settings with these options.
      '';

      example = literalExpression ''
        {
          eMule = {
            IncomingDir = "/mnt/hd/amule/Incoming";
            TempDir = "/mnt/hd/amule/Temp";
          };
          WebServer.Enabled = 1;
        }
      '';

      type = types.submodule {
        options = settingsOptions;
        freeformType = settingsFormat.type;
      };
    };

    user = mkOption {
      default = "amule";
      description = "The user the aMule daemon should run as";
      type = types.str;
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = isNull cfg.ExternalConnectPasswordFile -> cfg.settings.ExternalConnect.ECPassword != "";
        message = "Set only one between `ExternalConnectPasswordFile` and `settings.ExternalConnect.ECPassword`";
      }
    ]
    ++ optionals webServerEnabled [
      {
        assertion = isNull cfg.WebServerPasswordFile -> cfg.settings.WebServer.Password != "";
        message = "Set only one between `ExternalWebServerFile` `settings.WebServer.Password`";
      }
    ];

    networking.firewall = mkMerge [
      (mkIf cfg.openPeerPorts {
        allowedTCPPorts = [ cfg.settings.eMule.Port ];
        allowedUDPPorts = [ cfg.settings.eMule.UDPPort ];
      })
      (mkIf cfg.openWebServerPort {
        allowedTCPPorts = [ cfg.settings.WebServer.Port ];
      })
    ];

    services.amule.settings = {
      eMule.AppVersion = lib.getVersion cfg.package;
    };

    systemd.services.amuled = {
      after = [ "network.target" ];
      description = "AMule daemon";
      path = [ pkgs.crudini ];

      preStart = ''
        AMULE_CONF="${cfg.dataDir}/amule.conf"

        if [ ! -f "$AMULE_CONF" ]; then
          echo "First run detected: starting aMule to generate default configuration..."
          echo "aMule will fail with an error - this is expected and normal"
          rm -f ${cfg.dataDir}/lastversion
          set +e
          ${getExe cfg.package} --config-dir ${cfg.dataDir}
          set -e
        fi
      ''
      + (lib.concatMapAttrsStringSep "" (
        section:
        lib.concatMapAttrsStringSep "" (
          param: value: ''
            crudini --inplace --set "$AMULE_CONF" "${section}" "${param}" "${builtins.toString value}"
          ''
        )
      ) cfg.settings)
      + optionalString (!isNull cfg.ExternalConnectPasswordFile) ''
        EC_PASSWORD=$(cat ${cfg.ExternalConnectPasswordFile} | md5sum | cut -d ' ' -f 1)
        crudini --inplace --set "$AMULE_CONF" "ExternalConnect" "ECPassword" "$EC_PASSWORD"
      ''
      + optionalString (!isNull cfg.WebServerPasswordFile) ''
        WEB_PASSWORD=$(cat ${cfg.WebServerPasswordFile} | md5sum | cut -d ' ' -f 1)
        crudini --inplace --set "$AMULE_CONF" "WebServer" "Password" "$WEB_PASSWORD"
      '';

      serviceConfig = {
        DevicePolicy = "closed";

        ExecStart = utils.escapeSystemdExecArgs (
          [
            (getExe cfg.package)
            "--config-dir"
            cfg.dataDir
          ]
          ++ optionals webServerEnabled [ "--use-amuleweb=${getExe cfg.amuleWebPackage}" ]
          ++ cfg.extraArgs
        );

        Group = cfg.group;
        LockPersonality = true;
        # Hardening
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateTmp = true;
        ProtectControlGroups = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectSystem = "strict";

        ReadWritePaths = [
          cfg.dataDir
          cfg.settings.eMule.TempDir
          cfg.settings.eMule.IncomingDir
        ];

        Restart = "on-failure";
        RestartSec = "5s";
        RestrictAddressFamilies = "AF_INET";
        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        User = cfg.user;
      };

      wantedBy = [ "multi-user.target" ];
    };

    systemd.tmpfiles.settings."10-amuled".${cfg.dataDir}.d = {
      inherit (cfg) user group;
      mode = "0755";
    };

    users.groups = optionalAttrs (cfg.group == "amule") {
      amule.gid = config.ids.gids.amule;
    };

    users.users = optionalAttrs (cfg.user == "amule") {
      amule = {
        description = "aMule user";
        group = cfg.group;
        isSystemUser = true;
        uid = config.ids.uids.amule;
      };
    };
  };

  meta = {
    doc = ./amuled.md;
    maintainers = with lib.maintainers; [ aciceri ];
  };
}

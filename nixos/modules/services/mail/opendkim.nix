{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.opendkim;

  defaultSock = "local:/run/opendkim/opendkim.sock";

  args = [
    "-f"
    "-l"
    "-p"
    cfg.socket
    "-d"
    cfg.domains
    "-k"
    "${cfg.keyPath}/${cfg.selector}.private"
    "-s"
    cfg.selector
  ]
  ++ lib.optionals (cfg.configFile != null) [
    "-x"
    cfg.configFile
  ];

  configFile = pkgs.writeText "opendkim.conf" (
    lib.concatStringsSep "\n" (lib.mapAttrsToList (name: value: "${name} ${value}") cfg.settings)
  );
in
{
  imports = [
    (lib.mkRenamedOptionModule [ "services" "opendkim" "keyFile" ] [ "services" "opendkim" "keyPath" ])
  ];

  options = {
    services.opendkim = {
      enable = lib.mkEnableOption "OpenDKIM sender authentication system";

      # TODO: deprecate this?
      configFile = lib.mkOption {
        default = null;
        description = "Additional opendkim configuration as a file.";
        type = lib.types.nullOr lib.types.path;
      };

      domains = lib.mkOption {
        default = "csl:${config.networking.hostName}";
        defaultText = lib.literalExpression ''"csl:''${config.networking.hostName}"'';

        description = ''
          Local domains set (see {manpage}`opendkim(8)` for more information on datasets).
          Messages from them are signed, not verified.
        '';

        example = "csl:example.com,mydomain.net";
        type = lib.types.str;
      };

      group = lib.mkOption {
        default = "opendkim";
        description = "Group for the daemon.";
        type = lib.types.str;
      };

      keyPath = lib.mkOption {
        default = "/var/lib/opendkim/keys";

        description = ''
          The path that opendkim should put its generated private keys into.
          The DNS settings will be found in this directory with the name selector.txt.
        '';

        type = lib.types.path;
      };

      selector = lib.mkOption {
        description = "Selector to use when signing.";
        type = lib.types.str;
      };

      settings = lib.mkOption {
        default = { };
        description = "Additional opendkim configuration";

        type =
          with lib.types;
          submodule {
            freeformType = attrsOf str;
          };
      };

      socket = lib.mkOption {
        default = defaultSock;
        description = "Socket which is used for communication with OpenDKIM.";
        type = lib.types.str;
      };

      user = lib.mkOption {
        default = "opendkim";
        description = "User for the daemon.";
        type = lib.types.str;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    environment = {
      etc = lib.mkIf (cfg.settings != { }) {
        "opendkim/opendkim.conf".source = configFile;
      };

      systemPackages = [ pkgs.opendkim ];
    };

    services.opendkim.configFile = lib.mkIf (cfg.settings != { }) configFile;

    systemd.services.opendkim = {
      after = [ "network.target" ];
      description = "OpenDKIM signing and verification daemon";

      preStart = ''
        cd "${cfg.keyPath}"
        if ! test -f ${cfg.selector}.private; then
          ${pkgs.opendkim}/bin/opendkim-genkey -s ${cfg.selector} -d all-domains-generic-key
          echo "Generated OpenDKIM key! Please update your DNS settings:\n"
          echo "-------------------------------------------------------------"
          cat ${cfg.selector}.txt
          echo "-------------------------------------------------------------"
        fi
      '';

      serviceConfig = {
        AmbientCapabilities = [ ];
        CapabilityBoundingSet = "";
        DevicePolicy = "closed";
        ExecStart = "${pkgs.opendkim}/bin/opendkim ${lib.escapeShellArgs args}";
        Group = cfg.group;
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateMounts = true;
        PrivateTmp = true;
        PrivateUsers = true;
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectSystem = "strict";
        ReadWritePaths = [ cfg.keyPath ];
        RemoveIPC = true;

        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6 AF_UNIX"
        ];

        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        RuntimeDirectory = lib.optional (cfg.socket == defaultSock) "opendkim";
        StateDirectory = "opendkim";
        StateDirectoryMode = "0700";
        SystemCallArchitectures = "native";

        SystemCallFilter = [
          "@system-service"
          "~@privileged @resources"
        ];

        UMask = "0077";
        User = cfg.user;
      };

      wantedBy = [ "multi-user.target" ];
    };

    systemd.tmpfiles.rules = [
      "d '${cfg.keyPath}' - ${cfg.user} ${cfg.group} - -"
    ];

    users.groups = lib.optionalAttrs (cfg.group == "opendkim") {
      opendkim.gid = config.ids.gids.opendkim;
    };

    users.users = lib.optionalAttrs (cfg.user == "opendkim") {
      opendkim = {
        group = cfg.group;
        uid = config.ids.uids.opendkim;
      };
    };
  };
}

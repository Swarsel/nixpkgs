{
  config,
  lib,
  pkgs,
  ...
}:
let

  cfg = config.services.davmail;

  configType =
    with lib.types;
    oneOf [
      (attrsOf configType)
      str
      int
      bool
    ]
    // {
      description = "davmail config type (str, int, bool or attribute set thereof)";
    };

  toStr = val: if lib.isBool val then lib.boolToString val else toString val;

  linesForAttrs =
    attrs:
    lib.concatMap (
      name:
      let
        value = attrs.${name};
      in
      if lib.isAttrs value then
        map (line: name + "." + line) (linesForAttrs value)
      else
        [ "${name}=${toStr value}" ]
    ) (lib.attrNames attrs);

  configFile = pkgs.writeText "davmail.properties" (
    lib.concatStringsSep "\n" (linesForAttrs cfg.config)
  );

in

{
  options.services.davmail = {
    config = lib.mkOption {
      default = { };

      description = ''
        Davmail configuration. Refer to
        <http://davmail.sourceforge.net/serversetup.html>
        and <http://davmail.sourceforge.net/advanced.html>
        for details on supported values.
      '';

      example = lib.literalExpression ''
        {
          davmail.allowRemote = true;
          davmail.imapPort = 55555;
          davmail.bindAddress = "10.0.1.2";
          davmail.smtpSaveInSent = true;
          davmail.folderSizeLimit = 10;
          davmail.caldavAutoSchedule = false;
          log4j.logger.rootLogger = "DEBUG";
        }
      '';

      type = configType;
    };

    enable = lib.mkEnableOption "davmail, an MS Exchange gateway";

    url = lib.mkOption {
      description = "Outlook Web Access URL to access the exchange server, i.e. the base webmail URL.";
      example = "https://outlook.office365.com/EWS/Exchange.asmx";
      type = lib.types.str;
    };
  };

  config = lib.mkIf cfg.enable {

    environment.systemPackages = [ pkgs.davmail ];

    services.davmail.config = {
      davmail = lib.mapAttrs (name: lib.mkDefault) {
        caldavPort = 1080;
        disableUpdateCheck = true;
        imapPort = 1143;
        ldapPort = 1389;
        logFilePath = "/var/log/davmail/davmail.log";
        logFileSize = "1MB";
        mode = "auto";
        popPort = 1110;
        server = true;
        smtpPort = 1025;
        url = cfg.url;
      };

      log4j = {
        logger.davmail = lib.mkDefault "WARN";
        logger.httpclient.wire = lib.mkDefault "WARN";
        logger.org.apache.commons.httpclient = lib.mkDefault "WARN";
        rootLogger = lib.mkDefault "WARN";
      };
    };

    systemd.services.davmail = {
      after = [ "network.target" ];
      description = "DavMail POP/IMAP/SMTP Exchange Gateway";

      serviceConfig = {
        CapabilityBoundingSet = [ "" ];
        DeviceAllow = [ "" ];
        DynamicUser = "yes";
        ExecStart = "${pkgs.davmail}/bin/davmail ${configFile}";
        LockPersonality = true;
        LogsDirectory = "davmail";
        NoNewPrivileges = true;
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
        ProtectSystem = "strict";
        RemoveIPC = true;
        Restart = "on-failure";

        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
        ];

        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        SystemCallArchitectures = "native";
        SystemCallErrorNumber = "EPERM";
        SystemCallFilter = "@system-service";
        Type = "simple";
        UMask = "0077";

      };

      wantedBy = [ "multi-user.target" ];
    };
  };
}

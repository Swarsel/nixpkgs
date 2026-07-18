{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
let

  cfg = config.services.prosody-filer;

  settingsFormat = pkgs.formats.toml { };
  configFile = settingsFormat.generate "prosody-filer.toml" cfg.settings;
in
{

  options = {
    services.prosody-filer = {
      enable = mkEnableOption "Prosody Filer XMPP upload file server";

      settings = mkOption {
        defaultText = literalExpression ''
          {
            listenport = mkDefault "127.0.0.1:5050";
            uploadSubDir = mkDefault "upload/";
          }
        '';

        description = ''
          Configuration for Prosody Filer.
          Refer to <https://github.com/ThomasLeister/prosody-filer#configure-prosody-filer> for details on supported values.
        '';

        example = {
          secret = "mysecret";
          storeDir = "/srv/http/nginx/prosody-upload";
        };

        type = settingsFormat.type;
      };
    };
  };

  config = mkIf cfg.enable {
    services.prosody-filer.settings = {
      listenport = mkDefault "127.0.0.1:5050";
      uploadSubDir = mkDefault "upload/";
    };

    systemd.services.prosody-filer = {
      after = [ "network.target" ];
      description = "Prosody file upload server";

      serviceConfig = {
        CapabilityBoundingSet = "";
        ExecStart = "${pkgs.prosody-filer}/bin/prosody-filer -config ${configFile}";
        Group = "prosody-filer";
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
        ProtectProc = "noaccess";
        RemoveIPC = true;
        Restart = "on-failure";

        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
        ];

        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;

        SystemCallFilter = [
          "@system-service"
          "~@privileged"
        ];

        User = "prosody-filer";
      };

      wantedBy = [ "multi-user.target" ];
    };

    users.groups.prosody-filer = { };

    users.users.prosody-filer = {
      group = "prosody-filer";
      isSystemUser = true;
    };
  };
}

{
  config,
  lib,
  pkgs,
  utils,
  ...
}:
let
  cfg = config.services.immich-kiosk;
  format = pkgs.formats.json { };
  secretsReplacement = utils.genJqSecretsReplacement {
    loadCredential = true;
  } cfg.settings "/run/immich-kiosk/config.yaml";
in
{
  options.services.immich-kiosk = {
    enable = lib.mkEnableOption "Immich Kiosk slideshow service";
    package = lib.mkPackageOption pkgs "immich-kiosk" { };

    openFirewall = lib.mkOption {
      default = false;

      description = ''
        Whether to open the firewall for the immich-kiosk port.
      '';

      type = lib.types.bool;
    };

    settings = lib.mkOption {
      default = { };

      description = ''
        Configuration for immich-kiosk. See
        <https://docs.immichkiosk.app/configuration/>
        for available options. Secret values can be loaded from files using
        `._secret = "/path/to/secret";`.
      '';

      example = lib.literalExpression ''
        {
          immich_url = "https://immich.example.com";
          immich_api_key._secret = "/run/secrets/immich-kiosk-api-key";
          albums = [
            "4fa933cf-051f-4621-9ac7-8d06776c261c"
            "6466548c-4995-4fb5-ab1f-f63cc9ff3e5f"
          ];
          duration = 30;
          layout = "splitview";
          disable_ui = true;
        }
      '';

      type = lib.types.submodule {
        options = {
          immich_url = lib.mkOption {
            default = config.services.immich.settings.server.externalDomain;
            defaultText = lib.literalExpression "config.services.immich.settings.server.externalDomain";

            description = ''
              URL of the immich instance.
            '';

            type = lib.types.str;
          };

          kiosk.port = lib.mkOption {
            default = 3000;

            description = ''
              Port on which immich-kiosk will listen.
            '';

            type = lib.types.port;
          };
        };

        freeformType = format.type;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [ cfg.settings.kiosk.port ];

    systemd.services.immich-kiosk = {
      after = [ "immich-server.service" ];
      description = "Immich Kiosk slideshow service";
      preStart = secretsReplacement.script;

      serviceConfig = {
        # Hardening
        CapabilityBoundingSet = [ "" ];
        DynamicUser = true;
        ExecStart = lib.getExe cfg.package;
        Group = "immich-kiosk";
        LoadCredential = secretsReplacement.credentials;
        LockPersonality = true;
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
        Restart = "on-failure";
        RestartSec = 10;

        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
        ];

        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        RuntimeDirectory = "immich-kiosk";
        RuntimeDirectoryMode = "0700";
        SyslogIdentifier = "immich-kiosk";
        SystemCallArchitectures = "native";

        SystemCallFilter = [
          "@system-service"
          "~@privileged"
          "~@resources"
        ];

        Type = "simple";
        UMask = "0077";
        User = "immich-kiosk";
        WorkingDirectory = "/run/immich-kiosk";
      };

      wantedBy = [ "multi-user.target" ];
    };
  };

  meta.maintainers = with lib.maintainers; [ tlvince ];
}

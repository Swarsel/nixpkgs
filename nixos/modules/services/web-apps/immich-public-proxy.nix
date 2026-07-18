{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.immich-public-proxy;
  format = pkgs.formats.json { };
  inherit (lib)
    types
    mkIf
    mkOption
    mkEnableOption
    ;
in
{
  options.services.immich-public-proxy = {
    enable = mkEnableOption "Immich Public Proxy";
    package = lib.mkPackageOption pkgs "immich-public-proxy" { };

    immichUrl = mkOption {
      description = "URL of the Immich instance";
      type = types.str;
    };

    openFirewall = mkOption {
      default = false;
      description = "Whether to open the IPP port in the firewall";
      type = types.bool;
    };

    port = mkOption {
      default = 3000;
      description = "The port that IPP will listen on.";
      type = types.port;
    };

    settings = mkOption {
      default = { };

      description = ''
        Configuration for IPP. See <https://github.com/alangrainger/immich-public-proxy/blob/main/README.md#additional-configuration> for options and defaults.
      '';

      type = types.submodule {
        freeformType = format.type;
      };
    };
  };

  config = mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = mkIf cfg.openFirewall [ cfg.port ];

    systemd.services.immich-public-proxy = {
      after = [ "network.target" ];
      description = "Immich public proxy for sharing albums publicly without exposing your Immich instance";

      environment = {
        IMMICH_URL = cfg.immichUrl;
        IPP_CONFIG = "${format.generate "config.json" cfg.settings}";
        IPP_PORT = toString cfg.port;
      };

      serviceConfig = {
        # Hardening
        CapabilityBoundingSet = "";
        DynamicUser = true;
        ExecStart = lib.getExe cfg.package;
        Group = "ipp";
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
        Restart = "on-failure";
        RestartSec = 3;

        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
          "AF_UNIX"
        ];

        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        SyslogIdentifier = "ipp";
        Type = "simple";
        User = "ipp";
      };

      wantedBy = [ "multi-user.target" ];
    };
  };

  meta.maintainers = with lib.maintainers; [ jaculabilis ];
}

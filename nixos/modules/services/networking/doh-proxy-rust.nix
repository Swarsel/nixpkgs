{
  config,
  lib,
  pkgs,
  ...
}:
let

  cfg = config.services.doh-proxy-rust;

in
{

  options.services.doh-proxy-rust = {

    enable = lib.mkEnableOption "doh-proxy-rust";

    flags = lib.mkOption {
      default = [ ];

      description = ''
        A list of command-line flags to pass to doh-proxy. For details on the
        available options, see <https://github.com/jedisct1/doh-server#usage>.
      '';

      example = [ "--server-address=9.9.9.9:53" ];
      type = lib.types.listOf lib.types.str;
    };

  };

  config = lib.mkIf cfg.enable {
    systemd.services.doh-proxy-rust = {
      after = [
        "network.target"
        "nss-lookup.target"
      ];

      description = "doh-proxy-rust";

      serviceConfig = {
        CapabilityBoundingSet = "";
        DynamicUser = true;
        ExecStart = "${pkgs.doh-proxy-rust}/bin/doh-proxy ${lib.escapeShellArgs cfg.flags}";
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        NoNewPrivileges = true;
        ProtectClock = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        RemoveIPC = true;
        Restart = "always";
        RestartSec = 10;
        RestrictAddressFamilies = "AF_INET AF_INET6";
        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        SystemCallArchitectures = "native";
        SystemCallErrorNumber = "EPERM";

        SystemCallFilter = [
          "@system-service"
          "~@privileged @resources"
        ];
      };

      wantedBy = [ "multi-user.target" ];
    };
  };

  meta.maintainers = with lib.maintainers; [ stephank ];

}

{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib)
    escapeShellArgs
    getExe
    lists
    literalExpression
    maintainers
    mkEnableOption
    mkIf
    mkOption
    mkPackageOption
    types
    ;

  cfg = config.services.dnsproxy;

  yaml = pkgs.formats.yaml { };
  configFile = yaml.generate "config.yaml" cfg.settings;

  finalFlags = (lists.optional (cfg.settings != { }) "--config-path=${configFile}") ++ cfg.flags;
in
{

  options.services.dnsproxy = {

    enable = mkEnableOption "dnsproxy";
    package = mkPackageOption pkgs "dnsproxy" { };

    flags = mkOption {
      default = [ ];

      description = ''
        A list of extra command-line flags to pass to dnsproxy. For details on the
        available options, see <https://github.com/AdguardTeam/dnsproxy#usage>.
        Keep in mind that options passed through command-line flags override
        config options.
      '';

      example = [ "--upstream=1.1.1.1:53" ];
      type = types.listOf types.str;
    };

    settings = mkOption {
      default = { };

      description = ''
        Contents of the {file}`config.yaml` config file.
        The `--config-path` argument will only be passed if this set is not empty.

        See <https://github.com/AdguardTeam/dnsproxy/blob/master/config.yaml.dist>.
      '';

      example = literalExpression ''
        {
          bootstrap = [
            "8.8.8.8:53"
          ];
          listen-addrs = [
            "0.0.0.0"
          ];
          listen-ports = [
            53
          ];
          upstream = [
            "1.1.1.1:53"
          ];
        }
      '';

      type = yaml.type;
    };

  };

  config = mkIf cfg.enable {
    systemd.services.dnsproxy = {
      after = [
        "network.target"
        "nss-lookup.target"
      ];

      description = "Simple DNS proxy with DoH, DoT, DoQ and DNSCrypt support";

      serviceConfig = {
        AmbientCapabilities = "CAP_NET_BIND_SERVICE";
        DynamicUser = true;
        ExecStart = "${getExe cfg.package} ${escapeShellArgs finalFlags}";
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

        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
        ];

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

  meta.maintainers = with maintainers; [ diogotcorreia ];

}

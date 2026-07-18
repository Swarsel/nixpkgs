{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.coredns;
  configFile = pkgs.writeText "Corefile" cfg.config;
in
{
  options.services.coredns = {
    config = lib.mkOption {
      default = "";

      description = ''
        Verbatim Corefile to use.
        See <https://coredns.io/manual/toc/#configuration> for details.
      '';

      example = ''
        . {
          whoami
        }
      '';

      type = lib.types.lines;
    };

    enable = lib.mkEnableOption "Coredns dns server";
    package = lib.mkPackageOption pkgs "coredns" { };

    extraArgs = lib.mkOption {
      default = [ ];
      description = "Extra arguments to pass to coredns.";
      example = [ "-dns.port=53" ];
      type = lib.types.listOf lib.types.str;
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.coredns = {
      after = [ "network.target" ];
      description = "Coredns dns server";

      serviceConfig = {
        AmbientCapabilities = "cap_net_bind_service";
        CapabilityBoundingSet = "cap_net_bind_service";
        DynamicUser = true;
        ExecReload = "${pkgs.coreutils}/bin/kill -SIGUSR1 $MAINPID";
        ExecStart = "${lib.getBin cfg.package}/bin/coredns -conf=${configFile} ${lib.escapeShellArgs cfg.extraArgs}";
        LimitNOFILE = 1048576;
        LimitNPROC = 512;
        NoNewPrivileges = true;
        Restart = "on-failure";
      };

      wantedBy = [ "multi-user.target" ];
    };
  };
}

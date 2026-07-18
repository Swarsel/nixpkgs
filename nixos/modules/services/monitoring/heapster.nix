{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.heapster;
in
{
  options.services.heapster = {
    enable = lib.mkEnableOption "Heapster monitoring";
    package = lib.mkPackageOption pkgs "heapster" { };

    extraOpts = lib.mkOption {
      default = "";
      description = "Heapster extra options";
      type = lib.types.separatedString " ";
    };

    sink = lib.mkOption {
      description = "Heapster metic sink";
      example = "influxdb:http://localhost:8086";
      type = lib.types.str;
    };

    source = lib.mkOption {
      description = "Heapster metric source";
      example = "kubernetes:https://kubernetes.default";
      type = lib.types.str;
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.heapster = {
      after = [
        "cadvisor.service"
        "kube-apiserver.service"
      ];

      serviceConfig = {
        ExecStart = "${cfg.package}/bin/heapster --source=${cfg.source} --sink=${cfg.sink} ${cfg.extraOpts}";
        User = "heapster";
      };

      wantedBy = [ "multi-user.target" ];
    };

    users.groups.heapster = { };

    users.users.heapster = {
      description = "Heapster user";
      group = "heapster";
      isSystemUser = true;
    };
  };
}

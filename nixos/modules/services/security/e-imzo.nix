{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.e-imzo;
in
{
  options = {
    services.e-imzo = {
      enable = lib.mkEnableOption "E-IMZO";

      package = lib.mkPackageOption pkgs "e-imzo" {
        extraDescription = "Official mirror deletes old versions as soon as they release new one. Feel free to use either unstable or your own custom e-imzo package and ping maintainer.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.user.services.e-imzo = {
      enable = true;

      after = [
        "network-online.target"
        "graphical.target"
      ];

      description = "E-IMZO, uzbek state web signing service";
      documentation = [ "https://github.com/xinux-org/e-imzo" ];

      serviceConfig = {
        ExecStart = lib.getExe cfg.package;

        ExecStartPre = [
          (pkgs.writeShellScript "e-imzo-check-port-availability" ''
            until [ -z "$(${pkgs.iproute2}/bin/ss -tuln | grep -E ':(64646|64443)\>')" ]; do
              sleep 1
            done
          '')
        ];

        NoNewPrivileges = true;
        Restart = "always";
        RestartSec = 1;
        SystemCallArchitectures = "native";
        Type = "simple";
      };

      wantedBy = [ "default.target" ];

      wants = [
        "network-online.target"
        "graphical.target"
      ];
    };
  };

  meta.maintainers = with lib.maintainers; [
    orzklv
    shakhzodkudratov
    bahrom04
    bemeritus
  ];
}

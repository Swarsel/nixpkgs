{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.realm;
  configFormat = pkgs.formats.json { };
  configFile = configFormat.generate "config.json" cfg.config;
  inherit (lib)
    mkEnableOption
    mkPackageOption
    mkOption
    mkIf
    types
    getExe
    ;
in
{

  options = {
    services.realm = {
      config = mkOption {
        default = { };

        description = ''
          The realm configuration, see <https://github.com/zhboner/realm#overview> for documentation.
        '';

        type = types.submodule {
          freeformType = configFormat.type;
        };
      };

      enable = mkEnableOption "A simple, high performance relay server written in rust";
      package = mkPackageOption pkgs "realm" { };
    };
  };

  config = mkIf cfg.enable {
    systemd.services.realm = {
      serviceConfig = {
        AmbientCapabilities = [
          "CAP_NET_ADMIN"
          "CAP_NET_BIND_SERVICE"
        ];

        DynamicUser = true;
        ExecStart = "${getExe cfg.package} --config ${configFile}";
        MemoryDenyWriteExecute = true;
        PrivateDevices = true;
        ProtectClock = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectProc = "invisible";
      };

      wantedBy = [ "multi-user.target" ];
    };
  };

  meta.maintainers = with lib.maintainers; [ ocfox ];
}

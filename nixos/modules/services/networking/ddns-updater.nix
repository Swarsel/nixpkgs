{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.ddns-updater;
in
{
  options.services.ddns-updater = {
    enable = lib.mkEnableOption "Container to update DNS records periodically with WebUI for many DNS providers";
    package = lib.mkPackageOption pkgs "ddns-updater" { };

    environment = lib.mkOption {
      default = { };
      description = "Environment variables to be set for the ddns-updater service. DATADIR is ignored to enable using systemd DynamicUser. For full list see <https://github.com/qdm12/ddns-updater>";
      type = lib.types.attrsOf lib.types.str;
    };
  };

  config = lib.mkIf cfg.enable {

    systemd.services.ddns-updater = {
      after = [ "network-online.target" ];

      environment = cfg.environment // {
        DATADIR = "%S/ddns-updater";
      };

      serviceConfig = {
        DynamicUser = true;
        ExecStart = lib.getExe cfg.package;
        Restart = "on-failure";
        RestartSec = 30;
        StateDirectory = "ddns-updater";
        TimeoutSec = "5min";
      };

      unitConfig = {
        Description = "DDNS-updater service";
      };

      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
    };
  };
}

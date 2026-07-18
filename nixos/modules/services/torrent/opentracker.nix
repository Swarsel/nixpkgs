{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.opentracker;
in
{
  options.services.opentracker = {
    enable = lib.mkEnableOption "opentracker";
    package = lib.mkPackageOption pkgs "opentracker" { };

    extraOptions = lib.mkOption {
      default = "";

      description = ''
        Configuration Arguments for opentracker
        See <https://erdgeist.org/arts/software/opentracker/> for all params
      '';

      type = lib.types.separatedString " ";
    };
  };

  config = lib.mkIf cfg.enable {

    systemd.services.opentracker = {
      after = [ "network.target" ];
      description = "opentracker server";
      restartIfChanged = true;

      serviceConfig = {
        ExecStart = "${cfg.package}/bin/opentracker ${cfg.extraOptions}";
        PrivateTmp = true;
        WorkingDirectory = "/var/empty";
        # By default opentracker drops all privileges and runs in chroot after starting up as root.
      };

      wantedBy = [ "multi-user.target" ];
    };
  };
}

{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.arbtt;
in
{
  options = {
    services.arbtt = {
      enable = lib.mkEnableOption "Arbtt statistics capture service";
      package = lib.mkPackageOption pkgs [ "haskellPackages" "arbtt" ] { };

      logFile = lib.mkOption {
        default = "%h/.arbtt/capture.log";

        description = ''
          The log file for captured samples.
        '';

        example = "/home/username/.arbtt-capture.log";
        type = lib.types.str;
      };

      sampleRate = lib.mkOption {
        default = 60;

        description = ''
          The sampling interval in seconds.
        '';

        example = 120;
        type = lib.types.int;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.user.services.arbtt = {
      description = "arbtt statistics capture service";
      partOf = [ "graphical-session.target" ];

      serviceConfig = {
        ExecStart = "${cfg.package}/bin/arbtt-capture --logfile=${cfg.logFile} --sample-rate=${toString cfg.sampleRate}";
        Restart = "always";
        Type = "simple";
      };

      wantedBy = [ "graphical-session.target" ];
    };
  };

  meta.maintainers = [ ];
}

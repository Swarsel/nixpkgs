{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.byedpi;
in
{
  options.services.byedpi = {
    enable = lib.mkEnableOption "the ByeDPI service";
    package = lib.mkPackageOption pkgs "byedpi" { };

    extraArgs = lib.mkOption {
      default = [ ];
      description = "Extra command line arguments.";

      example = [
        "--split"
        "1"
        "--disorder"
        "3+s"
        "--mod-http=h,d"
        "--auto=torst"
        "--tlsrec"
        "1+s"
      ];

      type = with lib.types; listOf str;
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.byedpi = {
      after = [
        "network-online.target"
        "nss-lookup.target"
      ];

      description = "ByeDPI";

      serviceConfig = {
        ExecStart = lib.escapeShellArgs ([ (lib.getExe cfg.package) ] ++ cfg.extraArgs);
        NoNewPrivileges = "yes";
        PrivateTmp = "true";
        ProtectSystem = "full";
        StandardError = "journal";
        StandardOutput = "null";
        TimeoutStopSec = "5s";
      };

      wantedBy = [ "default.target" ];
      wants = [ "network-online.target" ];
    };
  };

  meta.maintainers = with lib.maintainers; [ wozrer ];
}

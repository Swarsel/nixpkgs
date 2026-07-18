{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.lldpd;

in

{
  options.services.lldpd = {
    enable = lib.mkEnableOption "Link Layer Discovery Protocol Daemon";

    extraArgs = lib.mkOption {
      default = [ ];
      description = "List of command line parameters for lldpd";

      example = [
        "-c"
        "-k"
        "-I eth0"
      ];

      type = lib.types.listOf lib.types.str;
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.lldpd ];
    systemd.packages = [ pkgs.lldpd ];

    systemd.services.lldpd = {
      environment.LLDPD_OPTIONS = lib.concatStringsSep " " cfg.extraArgs;
      wantedBy = [ "multi-user.target" ];
    };

    users.groups._lldpd = { };

    users.users._lldpd = {
      description = "lldpd user";
      group = "_lldpd";
      home = "/run/lldpd";
      isSystemUser = true;
    };
  };
}

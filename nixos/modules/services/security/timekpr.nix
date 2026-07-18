{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.timekpr;
  targetBaseDir = "/var/lib/timekpr";
  daemonUser = "root";
  daemonGroup = "root";
in
{
  options = {
    services.timekpr = {
      enable = lib.mkEnableOption "Timekpr-nExT, a screen time managing application that helps optimizing time spent at computer for your subordinates, children or even for yourself";
      package = lib.mkPackageOption pkgs "timekpr" { };

      adminUsers = lib.mkOption {
        default = [ ];

        description = ''
          All listed users will become part of the `timekpr` group so they can manage timekpr settings without requiring sudo.
        '';

        example = [
          "alice"
          "bob"
        ];

        type = lib.types.listOf lib.types.str;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    environment.etc."timekpr" = {
      source = "${cfg.package}/etc/timekpr";
    };

    environment.systemPackages = [
      # Add timekpr to system packages so that polkit can find it
      cfg.package
    ];

    security.polkit.enable = true;
    services.dbus.enable = true;

    services.dbus.packages = [
      cfg.package
    ];

    systemd.packages = [
      cfg.package
    ];

    systemd.services.timekpr = {
      enable = true;
      wantedBy = [ "multi-user.target" ];
    };

    systemd.tmpfiles.rules = [
      "d ${targetBaseDir} 0755 ${daemonUser} ${daemonGroup} -"
      "d ${targetBaseDir}/config 0755 ${daemonUser} ${daemonGroup} -"
      "d ${targetBaseDir}/work 0755 ${daemonUser} ${daemonGroup} -"
    ];

    users.groups.timekpr = {
      gid = 2000;
      members = cfg.adminUsers;
    };
  };

  meta.maintainers = [ lib.maintainers.atry ];
}

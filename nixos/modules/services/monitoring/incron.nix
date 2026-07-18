{
  config,
  lib,
  pkgs,
  ...
}:
let

  cfg = config.services.incron;

in

{
  options = {

    services.incron = {

      enable = lib.mkOption {
        default = false;

        description = ''
          Whether to enable the incron daemon.

          Note that commands run under incrontab only support common Nix profiles for the {env}`PATH` provided variable.
        '';

        type = lib.types.bool;
      };

      allow = lib.mkOption {
        default = null;

        description = ''
          Users allowed to use incrontab.

          If empty then no user will be allowed to have their own incrontab.
          If `null` then will defer to {option}`deny`.
          If both {option}`allow` and {option}`deny` are null
          then all users will be allowed to have their own incrontab.
        '';

        type = lib.types.nullOr (lib.types.listOf lib.types.str);
      };

      deny = lib.mkOption {
        default = null;
        description = "Users forbidden from using incrontab.";
        type = lib.types.nullOr (lib.types.listOf lib.types.str);
      };

      extraPackages = lib.mkOption {
        default = [ ];
        description = "Extra packages available to the system incrontab.";
        example = lib.literalExpression "[ pkgs.rsync ]";
        type = lib.types.listOf lib.types.package;
      };

      systab = lib.mkOption {
        default = "";
        description = "The system incrontab contents.";

        example = ''
          /var/mail IN_CLOSE_WRITE abc $@/$#
          /tmp IN_ALL_EVENTS efg $@/$# $&
        '';

        type = lib.types.lines;
      };

    };

  };

  config = lib.mkIf cfg.enable {

    environment.etc."incron.allow" = lib.mkIf (cfg.allow != null) {
      text = lib.concatStringsSep "\n" cfg.allow;
    };

    # incron won't read symlinks
    environment.etc."incron.d/system" = {
      mode = "0444";
      text = cfg.systab;
    };

    environment.etc."incron.deny" = lib.mkIf (cfg.deny != null) {
      text = lib.concatStringsSep "\n" cfg.deny;
    };

    environment.systemPackages = [ pkgs.incron ];

    security.wrappers.incrontab = {
      group = "root";
      owner = "root";
      setuid = true;
      source = "${pkgs.incron}/bin/incrontab";
    };

    systemd.services.incron = {
      description = "File System Events Scheduler";
      path = cfg.extraPackages;
      serviceConfig.ExecStart = "${pkgs.incron}/bin/incrond --foreground";
      serviceConfig.ExecStartPre = "${pkgs.coreutils}/bin/mkdir -m 710 -p /var/spool/incron";
      serviceConfig.PIDFile = "/run/incrond.pid";
      wantedBy = [ "multi-user.target" ];
    };

    warnings = lib.optional (
      cfg.allow != null && cfg.deny != null
    ) "If `services.incron.allow` is set then `services.incron.deny` will be ignored.";
  };

}

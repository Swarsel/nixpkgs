{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.rsnapshot;
  cfgfile = pkgs.writeText "rsnapshot.conf" ''
    config_version	1.2
    cmd_cp	${pkgs.coreutils}/bin/cp
    cmd_rm	${pkgs.coreutils}/bin/rm
    cmd_rsync	${pkgs.rsync}/bin/rsync
    cmd_ssh	${pkgs.openssh}/bin/ssh
    cmd_logger	${pkgs.inetutils}/bin/logger
    cmd_du	${pkgs.coreutils}/bin/du
    cmd_rsnapshot_diff	${pkgs.rsnapshot}/bin/rsnapshot-diff
    lockfile	/run/rsnapshot.pid
    link_dest	1

    ${cfg.extraConfig}
  '';
in
{
  options = {
    services.rsnapshot = {
      enable = lib.mkEnableOption "rsnapshot backups";

      cronIntervals = lib.mkOption {
        default = { };

        description = ''
          Periodicity at which intervals should be run by cron.
          Note that the intervals also have to exist in configuration
          as retain options.
        '';

        example = {
          daily = "50 21 * * *";
          hourly = "0 * * * *";
        };

        type = lib.types.attrsOf lib.types.str;
      };

      enableManualRsnapshot = lib.mkOption {
        default = true;
        description = "Whether to enable manual usage of the rsnapshot command with this module.";
        type = lib.types.bool;
      };

      extraConfig = lib.mkOption {
        default = "";

        description = ''
          rsnapshot configuration option in addition to the defaults from
          rsnapshot and this module.

          Note that tabs are required to separate option arguments, and
          directory names require trailing slashes.

          The "extra" in the option name might be a little misleading right
          now, as it is required to get a functional configuration.
        '';

        example = ''
          retains	hourly	24
          retain	daily	365
          backup	/home/	localhost/
        '';

        type = lib.types.lines;
      };
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        services.cron.systemCronJobs = lib.mapAttrsToList (
          interval: time: "${time} root ${pkgs.rsnapshot}/bin/rsnapshot -c ${cfgfile} ${interval}"
        ) cfg.cronIntervals;
      }
      (lib.mkIf cfg.enableManualRsnapshot {
        environment.etc."rsnapshot.conf".source = cfgfile;
        environment.systemPackages = [ pkgs.rsnapshot ];
      })
    ]
  );
}

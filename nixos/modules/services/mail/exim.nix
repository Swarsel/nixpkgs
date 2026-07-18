{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib)
    mkIf
    mkOption
    types
    mkPackageOption
    ;
  inherit (pkgs) coreutils;
  cfg = config.services.exim;
in

{

  ###### interface

  options = {

    services.exim = {

      config = mkOption {
        default = "";

        description = ''
          Verbatim Exim configuration.  This should not contain exim_user,
          exim_group, exim_path, or spool_directory.
        '';

        type = types.lines;
      };

      enable = mkOption {
        default = false;
        description = "Whether to enable the Exim mail transfer agent.";
        type = types.bool;
      };

      package = mkPackageOption pkgs "exim" {
        extraDescription = ''
          This can be used to enable features such as LDAP or PAM support.
        '';
      };

      group = mkOption {
        default = "exim";

        description = ''
          Group to use when no root privileges are required.
        '';

        type = types.str;
      };

      queueRunnerInterval = mkOption {
        default = "5m";

        description = ''
          How often to spawn a new queue runner.
        '';

        type = types.str;
      };

      spoolDir = mkOption {
        default = "/var/spool/exim";

        description = ''
          Location of the spool directory of exim.
        '';

        type = types.path;
      };

      user = mkOption {
        default = "exim";

        description = ''
          User to use when no root privileges are required.
          In particular, this applies when receiving messages and when doing
          remote deliveries.  (Local deliveries run as various non-root users,
          typically as the owner of a local mailbox.) Specifying this value
          as root is not supported.
        '';

        type = types.str;
      };
    };

  };

  ###### implementation

  config = mkIf cfg.enable {

    environment = {
      etc."exim.conf".text = ''
        exim_user = ${cfg.user}
        exim_group = ${cfg.group}
        exim_path = /run/wrappers/bin/exim
        spool_directory = ${cfg.spoolDir}
        ${cfg.config}
      '';

      systemPackages = [ cfg.package ];
    };

    security.wrappers.exim = {
      group = "root";
      owner = "root";
      setuid = true;
      source = "${cfg.package}/bin/exim";
    };

    systemd.services.exim = {
      description = "Exim Mail Daemon";
      restartTriggers = [ config.environment.etc."exim.conf".source ];

      serviceConfig = {
        ExecReload = "!${coreutils}/bin/kill -HUP $MAINPID";
        ExecStart = "!${cfg.package}/bin/exim -bdf -q${cfg.queueRunnerInterval}";
        ExecStartPre = "+${coreutils}/bin/install --group=${cfg.group} --owner=${cfg.user} --mode=0700 --directory ${cfg.spoolDir}";
        User = cfg.user;
      };

      wantedBy = [ "multi-user.target" ];
    };

    users.groups.${cfg.group} = {
      gid = config.ids.gids.exim;
    };

    users.users.${cfg.user} = {
      description = "Exim mail transfer agent user";
      group = cfg.group;
      uid = config.ids.uids.exim;
    };
  };
}

{
  config,
  lib,
  pkgs,
  ...
}:
let

  cfg = config.services.autofs;

  autoMaster = pkgs.writeText "auto.master" cfg.autoMaster;

in

{

  ###### interface

  options = {

    services.autofs = {

      enable = lib.mkOption {
        default = false;

        description = ''
          Mount filesystems on demand. Unmount them automatically.
          You may also be interested in afuse.
        '';

        type = lib.types.bool;
      };

      autoMaster = lib.mkOption {
        description = ''
          Contents of `/etc/auto.master` file. See {manpage}`auto.master(5)` and {manpage}`autofs(5)`.
        '';

        example = lib.literalExpression ''
          let
            mapConf = pkgs.writeText "auto" '''
             kernel    -ro,soft,intr       ftp.kernel.org:/pub/linux
             boot      -fstype=ext2        :/dev/hda1
             windoze   -fstype=smbfs       ://windoze/c
             removable -fstype=ext2        :/dev/hdd
             cd        -fstype=iso9660,ro  :/dev/hdc
             floppy    -fstype=auto        :/dev/fd0
             server    -rw,hard,intr       / -ro myserver.me.org:/ \
                                           /usr myserver.me.org:/usr \
                                           /home myserver.me.org:/home
            ''';
          in '''
            /auto file:''${mapConf}
          '''
        '';

        type = lib.types.str;
      };

      debug = lib.mkOption {
        default = false;

        description = ''
          Pass -d and -7 to automount and write log to the system journal.
        '';

        type = lib.types.bool;
      };

      timeout = lib.mkOption {
        default = 600;
        description = "Set the global minimum timeout, in seconds, until directories are unmounted";
        type = lib.types.int;
      };

    };

  };

  ###### implementation

  config = lib.mkIf cfg.enable {

    boot.kernelModules = [ "autofs" ];

    systemd.services.autofs = {
      after = [
        "network.target"
        "ypbind.service"
        "sssd.service"
        "network-online.target"
      ];

      description = "Automounts filesystems on demand";

      serviceConfig = {
        ExecReload = "${pkgs.coreutils}/bin/kill -HUP $MAINPID";
        ExecStart = "${pkgs.autofs5}/bin/automount ${lib.optionalString cfg.debug "-d"} -p /run/autofs.pid -t ${toString cfg.timeout} ${autoMaster}";
        # There should be only one autofs service managed by systemd, so this should be safe.
        ExecStartPre = "${lib.getExe' pkgs.coreutils "rm"} -f /tmp/autofs-running";
        PIDFile = "/run/autofs.pid";
        Type = "forking";
      };

      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
    };

  };

}

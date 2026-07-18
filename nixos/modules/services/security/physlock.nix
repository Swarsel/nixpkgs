{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.physlock;
in

{

  ###### interface

  options = {

    services.physlock = {

      enable = lib.mkOption {
        default = false;

        description = ''
          Whether to enable the {command}`physlock` screen locking mechanism.

          Enable this and then run {command}`systemctl start physlock`
          to securely lock the screen.

          This will switch to a new virtual terminal, turn off console
          switching and disable SysRq mechanism (when
          {option}`services.physlock.disableSysRq` is set)
          until the root or user password is given.
        '';

        type = lib.types.bool;
      };

      allowAnyUser = lib.mkOption {
        default = false;

        description = ''
          Whether to allow any user to lock the screen. This will install a
          setuid wrapper to allow any user to start physlock as root, which
          is a minor security risk. Call the physlock binary to use this instead
          of using the systemd service.
        '';

        type = lib.types.bool;
      };

      disableSysRq = lib.mkOption {
        default = true;

        description = ''
          Whether to disable SysRq when locked with physlock.
        '';

        type = lib.types.bool;
      };

      lockMessage = lib.mkOption {
        default = "";

        description = ''
          Message to show on physlock login terminal.
        '';

        type = lib.types.str;
      };

      lockOn = {

        extraTargets = lib.mkOption {
          default = [ ];

          description = ''
            Other targets to lock the screen just before.

            Useful if you want to e.g. both autologin to X11 so that
            your {file}`~/.xsession` gets executed and
            still to have the screen locked so that the system can be
            booted relatively unattended.
          '';

          example = [ "display-manager.service" ];
          type = lib.types.listOf lib.types.str;
        };

        hibernate = lib.mkOption {
          default = true;

          description = ''
            Whether to lock screen with physlock just before hibernate.
          '';

          type = lib.types.bool;
        };

        suspend = lib.mkOption {
          default = true;

          description = ''
            Whether to lock screen with physlock just before suspend.
          '';

          type = lib.types.bool;
        };

      };

      muteKernelMessages = lib.mkOption {
        default = false;

        description = ''
          Disable kernel messages on console while physlock is running.
        '';

        type = lib.types.bool;
      };

    };

  };

  ###### implementation

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {

        # for physlock -l and physlock -L
        environment.systemPackages = [ pkgs.physlock ];
        security.pam.services.physlock = { };

        systemd.services.physlock = {
          enable = true;

          before =
            lib.optional cfg.lockOn.suspend "systemd-suspend.service"
            ++ lib.optional cfg.lockOn.hibernate "systemd-hibernate.service"
            ++ lib.optional (
              cfg.lockOn.hibernate || cfg.lockOn.suspend
            ) "systemd-suspend-then-hibernate.service"
            ++ cfg.lockOn.extraTargets;

          description = "Physlock";
          documentation = [ "man:physlock(1)" ];

          serviceConfig = {
            ExecStart = "${pkgs.physlock}/bin/physlock -d${lib.optionalString cfg.muteKernelMessages "m"}${lib.optionalString cfg.disableSysRq "s"}${
              lib.optionalString (cfg.lockMessage != "") " -p \"${cfg.lockMessage}\""
            }";

            Type = "forking";
          };

          wantedBy =
            lib.optional cfg.lockOn.suspend "suspend.target"
            ++ lib.optional cfg.lockOn.hibernate "hibernate.target"
            ++ lib.optional (cfg.lockOn.hibernate || cfg.lockOn.suspend) "suspend-then-hibernate.target"
            ++ cfg.lockOn.extraTargets;
        };

      }

      (lib.mkIf cfg.allowAnyUser {

        security.wrappers.physlock = {
          group = "root";
          owner = "root";
          setuid = true;
          source = "${pkgs.physlock}/bin/physlock";
        };

      })
    ]
  );

}

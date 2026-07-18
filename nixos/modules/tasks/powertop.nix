{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.powerManagement.powertop;
in
{
  ###### interface

  options.powerManagement.powertop = {
    enable = mkEnableOption "powertop auto tuning on startup";

    postStart = mkOption {
      default = "";

      description = ''
        Shell commands executed after `powertop` is started.

        This can be used to workaround problematic configurations. For example,
        you can retrigger an `udev` rule to disable power saving on unsupported
        USB devices:
        ```
        services.udev.extraRules = ''''
          # disable USB auto suspend for Logitech, Inc. G PRO Gaming Mouse
          ACTION=="bind", SUBSYSTEM=="usb", ATTR{idVendor}=="046d", ATTR{idProduct}=="c08c", TEST=="power/control", ATTR{power/control}="on"
        '''';
        ```
      '';

      example = ''
        ''${lib.getExe' config.systemd.package "udevadm"} trigger -c bind -s usb -a idVendor=046d -a idProduct=c08c
      '';

      type = types.lines;
    };

    preStart = mkOption {
      default = "";

      description = ''
        Shell commands executed before `powertop` is started.
      '';

      type = types.lines;
    };
  };

  ###### implementation

  config = mkIf (cfg.enable) {
    systemd.services = {
      powertop = {
        after = [ "multi-user.target" ];
        description = "Powertop tunings";
        documentation = [ "man:powertop(8)" ];
        path = [ pkgs.kmod ];
        postStart = cfg.postStart;
        preStart = cfg.preStart;

        serviceConfig = {
          ExecStart = "${pkgs.powertop}/bin/powertop --auto-tune";
          RemainAfterExit = "yes";
          Type = "oneshot";
        };

        wantedBy = [ "multi-user.target" ];
      };
    };
  };
}

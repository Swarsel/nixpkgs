{
  config,
  lib,
  pkgs,
  ...
}:
let

  enabled = lib.elem "displaylink" config.services.xserver.videoDrivers;

  evdi = config.boot.kernelPackages.evdi;

  displaylink = pkgs.displaylink.override {
    inherit evdi;
  };

in

{

  config = lib.mkIf enabled {

    boot.extraModulePackages = [ evdi ];
    boot.kernelModules = [ "evdi" ];

    environment.etc."X11/xorg.conf.d/40-displaylink.conf".text = ''
      Section "OutputClass"
        Identifier  "DisplayLink"
        MatchDriver "evdi"
        Driver      "modesetting"
        Option      "TearFree" "true"
        Option      "AccelMethod" "none"
      EndSection
    '';

    powerManagement.powerDownCommands = ''
      #flush any bytes in pipe
      while read -n 1 -t 1 SUSPEND_RESULT < /tmp/PmMessagesPort_out; do : ; done;

      #suspend DisplayLinkManager
      echo "S" > /tmp/PmMessagesPort_in

      #wait until suspend of DisplayLinkManager finish
      if [ -f /tmp/PmMessagesPort_out ]; then
        #wait until suspend of DisplayLinkManager finish
        read -n 1 -t 10 SUSPEND_RESULT < /tmp/PmMessagesPort_out
      fi
    '';

    powerManagement.resumeCommands = ''
      #resume DisplayLinkManager
      echo "R" > /tmp/PmMessagesPort_in
    '';

    # Those are taken from displaylink-installer.sh and from Arch Linux AUR package.
    services.udev.packages = [ displaylink ];

    # make the device available
    services.xserver.displayManager.sessionCommands = ''
      ${lib.getBin pkgs.xrandr}/bin/xrandr --setprovideroutputsource 1 0
    '';

    services.xserver.externallyConfiguredDrivers = [ "displaylink" ];

    systemd.services.dlm = {
      after = [ "display-manager.service" ];
      conflicts = [ "getty@tty7.service" ];
      description = "DisplayLink Manager Service";

      serviceConfig = {
        ExecStart = "${displaylink}/bin/DisplayLinkManager";
        LogsDirectory = "displaylink";
        Restart = "always";
        RestartSec = 5;
      };
    };

  };

}

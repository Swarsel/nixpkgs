{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.infnoise;
in
{
  options = {
    services.infnoise = {
      enable = lib.mkEnableOption "the Infinite Noise TRNG driver";

      fillDevRandom = lib.mkOption {
        default = true;

        description = ''
          Whether to run the infnoise driver as a daemon to refill /dev/random.

          If disabled, you can use the `infnoise` command-line tool to
          manually obtain randomness.
        '';

        type = lib.types.bool;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.infnoise ];

    services.udev.extraRules = ''
      SUBSYSTEM=="usb", ATTRS{idVendor}=="0403", ATTRS{idProduct}=="6015", SYMLINK+="infnoise", TAG+="systemd", GROUP="dialout", MODE="0664", ENV{SYSTEMD_WANTS}="infnoise.service"
    '';

    systemd.services.infnoise = lib.mkIf cfg.fillDevRandom {
      after = [ "dev-infnoise.device" ];
      bindsTo = [ "dev-infnoise.device" ];
      description = "Infinite Noise TRNG driver";

      serviceConfig = {
        DeviceAllow = [ "/dev/infnoise" ];
        DevicePolicy = "closed";
        DynamicUser = true;
        ExecStart = "${pkgs.infnoise}/bin/infnoise --dev-random --debug";
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        PrivateNetwork = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true; # only reads entropy pool size and watermark
        ProtectSystem = "strict";
        Restart = "always";
        RestrictNamespaces = true;
        RestrictRealtime = true;
        SupplementaryGroups = [ "dialout" ];
        User = "infnoise";
      };
    };
  };
}

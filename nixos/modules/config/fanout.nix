{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.fanout;
  mknodCmds =
    n:
    lib.lists.imap0 (i: s: "mknod /dev/fanout${toString i} c $MAJOR ${toString i}") (
      lib.lists.replicate n ""
    );
in
{
  options.services.fanout = {
    enable = lib.mkEnableOption "fanout";

    bufferSize = lib.mkOption {
      default = 16384;
      description = "Size of /dev/fanout buffer in bytes";
      type = lib.types.int;
    };

    fanoutDevices = lib.mkOption {
      default = 1;
      description = "Number of /dev/fanout devices";
      type = lib.types.int;
    };
  };

  config = lib.mkIf cfg.enable {
    boot.extraModprobeConfig = ''
      options fanout buffersize=${toString cfg.bufferSize}
    '';

    boot.extraModulePackages = [ config.boot.kernelPackages.fanout.out ];
    boot.kernelModules = [ "fanout" ];

    systemd.services.fanout = {
      description = "Bring up /dev/fanout devices";

      script = ''
        MAJOR=$(${pkgs.gnugrep}/bin/grep fanout /proc/devices | ${pkgs.gawk}/bin/awk '{print $1}')
        ${lib.strings.concatLines (mknodCmds cfg.fanoutDevices)}
      '';

      serviceConfig = {
        RemainAfterExit = "yes";
        Restart = "no";
        Type = "oneshot";
        User = "root";
      };

      wantedBy = [ "multi-user.target" ];
    };
  };
}

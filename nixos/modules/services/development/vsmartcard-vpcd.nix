{
  config,
  lib,
  pkgs,
  ...
}:

let

  cfg = config.services.vsmartcard-vpcd;

in
{

  options.services.vsmartcard-vpcd = {
    enable = lib.mkEnableOption "Virtual smart card driver.";

    hostname = lib.mkOption {
      default = "/dev/null";

      description = ''
        Hostname of a waiting vpicc server vpcd will be connecting to. Use /dev/null for listening mode.
      '';

      type = lib.types.str;
    };

    port = lib.mkOption {
      default = 35963;

      description = ''
        Port number vpcd will be listening on.
      '';

      type = lib.types.port;
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.vsmartcard-vpcd ];

    services.pcscd.readerConfigs = [
      ''
        FRIENDLYNAME "Virtual PCD"
        DEVICENAME   ${cfg.hostname}:0x${lib.toHexString cfg.port}
        LIBPATH      ${pkgs.vsmartcard-vpcd}/var/lib/pcsc/drivers/serial/libifdvpcd.so
        CHANNELID    0x${lib.toHexString cfg.port}
      ''
    ];
  };

  meta.maintainers = with lib.maintainers; [ stargate01 ];
}

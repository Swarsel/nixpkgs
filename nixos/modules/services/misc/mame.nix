{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.mame;
  mame = "mame${lib.optionalString pkgs.stdenv.hostPlatform.is64bit "64"}";
in
{
  options = {
    services.mame = {
      enable = lib.mkOption {
        default = false;

        description = ''
          Whether to setup TUN/TAP Ethernet interface for MAME emulator.
        '';

        type = lib.types.bool;
      };

      emuAddr = lib.mkOption {
        description = ''
          IP address of the guest system. The same you set inside guest OS under
          MAME. Should be on the same subnet as {option}`services.mame.hostAddr`.
        '';

        example = "192.168.31.155";
        type = lib.types.str;
      };

      hostAddr = lib.mkOption {
        description = ''
          IP address of the host system. Usually an address of the main network
          adapter or the adapter through which you get an internet connection.
        '';

        example = "192.168.31.156";
        type = lib.types.str;
      };

      user = lib.mkOption {
        description = ''
          User from which you run MAME binary.
        '';

        type = lib.types.str;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.mame ];

    security.wrappers."${mame}" = {
      capabilities = "cap_net_admin,cap_net_raw+eip";
      group = "root";
      owner = "root";
      source = "${pkgs.mame}/bin/${mame}";
    };

    systemd.services.mame = {
      after = [ "network.target" ];
      description = "MAME TUN/TAP Ethernet interface";
      path = [ pkgs.iproute2 ];

      serviceConfig = {
        ExecStart = "${pkgs.mame}/bin/taputil.sh -c ${cfg.user} ${cfg.emuAddr} ${cfg.hostAddr} -";
        ExecStop = "${pkgs.mame}/bin/taputil.sh -d ${cfg.user}";
        RemainAfterExit = true;
        Type = "oneshot";
      };

      wantedBy = [ "multi-user.target" ];
    };
  };

  meta.maintainers = [ ];
}

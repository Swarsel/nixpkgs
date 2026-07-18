{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.trezord;
in
{

  ### interface
  options = {
    services.trezord = {
      enable = lib.mkOption {
        default = false;

        description = ''
          Enable Trezor bridge daemon, for use with Trezor hardware bitcoin wallets.
        '';

        type = lib.types.bool;
      };

      emulator.enable = lib.mkOption {
        default = false;

        description = ''
          Enable Trezor emulator support.
        '';

        type = lib.types.bool;
      };

      emulator.port = lib.mkOption {
        default = 21324;

        description = ''
          Listening port for the Trezor emulator.
        '';

        type = lib.types.port;
      };
    };
  };

  ### implementation
  config = lib.mkIf cfg.enable {
    services.udev.packages = [ pkgs.trezor-udev-rules ];

    systemd.services.trezord = {
      after = [ "network.target" ];
      description = "Trezor Bridge";
      path = [ ];

      serviceConfig = {
        ExecStart = "${pkgs.trezord}/bin/trezord-go ${lib.optionalString cfg.emulator.enable "-e ${toString cfg.emulator.port}"}";
        Type = "simple";
        User = "trezord";
      };

      wantedBy = [ "multi-user.target" ];
    };

    users.groups.trezord = { };

    users.users.trezord = {
      description = "Trezor bridge daemon user";
      group = "trezord";
      isSystemUser = true;
    };
  };

  ### docs
  meta = {
    doc = ./trezord.md;
  };
}

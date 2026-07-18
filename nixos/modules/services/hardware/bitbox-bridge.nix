{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.bitbox-bridge;
in
{
  options = {
    services.bitbox-bridge = {
      enable = lib.mkEnableOption "Bitbox bridge daemon, for use with Bitbox hardware wallets.";
      package = lib.mkPackageOption pkgs "bitbox-bridge" { };

      port = lib.mkOption {
        default = 8178;

        description = ''
          Listening port for the bitbox-bridge.
        '';

        type = lib.types.port;
      };

      runOnMount = lib.mkEnableOption null // {
        default = true;

        description = ''
          Run bitbox-bridge.service only when hardware wallet is plugged, also registers the systemd device unit.
          This option is enabled by default to save power, when false, bitbox-bridge service runs all the time instead.
        '';
      };
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];

    services.udev.packages = [
      cfg.package
    ]
    ++ lib.optionals (cfg.runOnMount) [
      (pkgs.writeTextFile {
        destination = "/etc/udev/rules.d/99-bitbox-bridge-run-on-mount.rules";
        name = "bitbox-bridge-run-on-mount-udev-rules";

        text = ''
          SUBSYSTEM=="usb", ATTRS{idVendor}=="03eb", ATTRS{idProduct}=="2403", MODE="0660", GROUP="bitbox", TAG+="systemd", SYMLINK+="bitbox02", ENV{SYSTEMD_WANTS}="bitbox-bridge.service"
        '';
      })
    ];

    systemd.services.bitbox-bridge = {
      after = [ "network.target" ];
      bindsTo = lib.optionals (cfg.runOnMount) [ "dev-bitbox02.device" ];
      description = "BitBox Bridge";

      serviceConfig = {
        ExecStart = "${cfg.package}/bin/bitbox-bridge -p ${toString cfg.port}";
        Type = "simple";
        User = "bitbox";
      };

      wantedBy = [ "multi-user.target" ];
    };

    users.groups.bitbox = { };

    users.users.bitbox = {
      description = "bitbox-bridge daemon user";
      extraGroups = [ "bitbox" ];
      group = "bitbox";
      isSystemUser = true;
    };
  };
}

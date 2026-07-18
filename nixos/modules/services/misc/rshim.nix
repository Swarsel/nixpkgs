{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.rshim;

  rshimCommand = [
    "${cfg.package}/bin/rshim"
  ]
  ++ lib.optionals (cfg.backend != null) [ "--backend ${cfg.backend}" ]
  ++ lib.optionals (cfg.device != null) [ "--device ${cfg.device}" ]
  ++ lib.optionals (cfg.index != null) [ "--index ${toString cfg.index}" ]
  ++ [ "--log-level ${toString cfg.log-level}" ];
in
{
  options.services.rshim = {
    config = lib.mkOption {
      default = { };

      description = ''
        Structural setting for the rshim configuration file
        (`/etc/rshim.conf`). It can be used to specify the static mapping
        between rshim devices and rshim names. It can also be used to ignore
        some rshim devices.
      '';

      example = {
        DISPLAY_LEVEL = 0;
        none = "usb-1-1.4";
        rshim0 = "usb-2-1.7";
      };

      type =
        with lib.types;
        attrsOf (oneOf [
          int
          str
        ]);
    };

    enable = lib.mkEnableOption "user-space rshim driver for the BlueField SoC";
    package = lib.mkPackageOption pkgs "rshim-user-space" { };

    backend = lib.mkOption {
      default = null;

      description = ''
        Specify the backend to attach. If not specified, the driver will scan
        all rshim backends unless the `device` option is given with a device
        name specified.
      '';

      example = "pcie";

      type =
        with lib.types;
        nullOr (enum [
          "usb"
          "pcie"
          "pcie_lf"
        ]);
    };

    device = lib.mkOption {
      default = null;

      description = ''
        Specify the device name to attach. The backend driver can be deduced
        from the device name, thus the `backend` option is not needed.
      '';

      example = "pcie-04:00.2";
      type = with lib.types; nullOr str;
    };

    index = lib.mkOption {
      default = null;

      description = ''
        Specify the index to create device path `/dev/rshim<index>`. It's also
        used to create network interface name `tmfifo_net<index>`. This option
        is needed when multiple rshim instances are running.
      '';

      example = 1;
      type = with lib.types; nullOr int;
    };

    log-level = lib.mkOption {
      default = 2;

      description = ''
        Specify the log level (0:none, 1:error, 2:warning, 3:notice, 4:debug).
      '';

      example = 4;
      type = lib.types.ints.between 0 4;
    };
  };

  config = lib.mkIf cfg.enable {
    environment.etc = lib.mkIf (cfg.config != { }) {
      "rshim.conf".text = lib.generators.toKeyValue {
        mkKeyValue = lib.generators.mkKeyValueDefault { } " ";
      } cfg.config;
    };

    systemd.services.rshim = {
      after = [ "network.target" ];

      serviceConfig = {
        ExecStart = [
          (lib.concatStringsSep " \\\n" rshimCommand)
        ];

        KillMode = "control-group";
        Restart = "always";
        Type = "forking";
      };

      wantedBy = [ "multi-user.target" ];
    };
  };

  meta.maintainers = with lib.maintainers; [ nikstur ];
}

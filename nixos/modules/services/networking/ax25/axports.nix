{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib)
    types
    ;

  inherit (lib.strings)
    concatStringsSep
    optionalString
    ;

  inherit (lib.attrsets)
    filterAttrs
    mapAttrsToList
    mapAttrs'
    ;

  inherit (lib.modules)
    mkIf
    ;

  inherit (lib.options)
    mkEnableOption
    mkOption
    mkPackageOption
    ;

  cfg = config.services.ax25.axports;

  enabledAxports = filterAttrs (ax25Name: cfg: cfg.enable) cfg;

  axportsOpts = {

    options = {
      enable = mkEnableOption "Enables the axport interface";
      package = mkPackageOption pkgs "ax25-tools" { };

      baud = mkOption {
        description = ''
          The serial port speed of this interface.
        '';

        example = 57600;
        type = types.int;
      };

      callsign = mkOption {
        description = ''
          The callsign of the physical interface to bind to.
        '';

        example = "WB6WLV-7";
        type = types.str;
      };

      description = mkOption {
        # This cannot be empty since some ax25 tools cant parse /etc/ax25/axports without it
        default = "NixOS managed tnc";

        description = ''
          Free format description of this interface.
        '';

        type = types.str;
      };

      kissParams = mkOption {
        default = null;

        description = ''
          Kissattach parameters for this interface.
        '';

        example = "-t 300 -l 10 -s 12 -r 80 -f n";
        type = types.nullOr types.str;
      };

      paclen = mkOption {
        default = 255;

        description = ''
          Default maximum packet size for this interface.
        '';

        type = types.int;
      };

      tty = mkOption {
        description = ''
          Location of hardware kiss tnc for this interface.
        '';

        example = "/dev/ttyACM0";
        type = types.str;
      };

      window = mkOption {
        default = 7;

        description = ''
          Default window size for this interface.
        '';

        type = types.int;
      };
    };
  };
in
{

  options = {

    services.ax25.axports = mkOption {
      default = { };
      description = "Specification of one or more AX.25 ports.";
      type = types.attrsOf (types.submodule axportsOpts);
    };
  };

  config = mkIf (enabledAxports != { }) {

    environment.etc."ax25/axports" = {
      mode = "0644";

      text = concatStringsSep "\n" (
        mapAttrsToList (
          portName: portCfg:
          "${portName} ${portCfg.callsign} ${toString portCfg.baud} ${toString portCfg.paclen} ${toString portCfg.window} ${portCfg.description}"
        ) enabledAxports
      );
    };

    system.requiredKernelConfig = [
      (config.lib.kernelConfig.isEnabled "ax25")
    ];

    systemd.services = mapAttrs' (portName: portCfg: {
      name = "ax25-kissattach-${portName}";

      value = {
        before = [ "ax25-axports.target" ];
        description = "AX.25 KISS attached interface for ${portName}";
        partOf = [ "ax25-axports.target" ];

        postStart = optionalString (portCfg.kissParams != null) ''
          ${portCfg.package}/bin/kissparms -p ${portName} ${portCfg.kissParams}
        '';

        serviceConfig = {
          ExecStart = "${portCfg.package}/bin/kissattach ${portCfg.tty} ${portName}";
          Type = "exec";
        };

        wantedBy = [ "multi-user.target" ];
      };
    }) enabledAxports;

    systemd.targets.ax25-axports = {
      description = "AX.25 axports group target";
    };
  };
}

{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf mkOption types;

  cfg = config.hardware.sensor.hddtemp;

  script = ''
    set -eEuo pipefail

    file=/var/lib/hddtemp/hddtemp.db

    raw_drives=""
    ${lib.concatStringsSep "\n" (map (drives: "raw_drives+=\"${drives} \"") cfg.drives)}
    drives=""
    for i in $raw_drives; do
      drives+=" $(realpath $i)"
    done

    cp ${pkgs.hddtemp}/share/hddtemp/hddtemp.db $file
    ${lib.concatMapStringsSep "\n" (e: "echo ${lib.escapeShellArg e} >> $file") cfg.dbEntries}

    ${pkgs.hddtemp}/bin/hddtemp ${lib.escapeShellArgs cfg.extraArgs} \
      --daemon \
      --unit=${cfg.unit} \
      --file=$file \
      $drives
  '';

in
{
  ###### interface
  options = {
    hardware.sensor.hddtemp = {
      enable = mkOption {
        default = false;

        description = ''
          Enable this option to support HDD/SSD temperature sensors.
        '';

        type = types.bool;
      };

      dbEntries = mkOption {
        default = [ ];
        description = "Additional DB entries";
        type = types.listOf types.str;
      };

      drives = mkOption {
        description = "List of drives to monitor. If you pass /dev/disk/by-path/* entries the symlinks will be resolved as hddtemp doesn't like names with colons.";
        type = types.listOf types.str;
      };

      extraArgs = mkOption {
        default = [ ];
        description = "Additional arguments passed to the daemon.";
        type = types.listOf types.str;
      };

      unit = mkOption {
        default = "C";
        description = "Celsius or Fahrenheit";

        type = types.enum [
          "C"
          "F"
        ];
      };
    };
  };

  ###### implementation
  config = mkIf cfg.enable {
    systemd.services.hddtemp = {
      inherit script;
      description = "HDD/SSD temperature";
      documentation = [ "man:hddtemp(8)" ];

      serviceConfig = {
        PrivateTmp = true;
        ProtectHome = "tmpfs";
        ProtectSystem = "strict";
        StateDirectory = "hddtemp";
        Type = "forking";
      };

      wantedBy = [ "multi-user.target" ];
    };
  };

  meta.maintainers = with lib.maintainers; [ peterhoeg ];
}

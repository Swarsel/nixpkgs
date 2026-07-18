{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib.options) mkEnableOption mkPackageOption mkOption;
  inherit (lib.modules) mkMerge mkIf;
  inherit (lib.lists) flatten filter imap0;
  inherit (lib.attrsets)
    recursiveUpdate
    mapAttrsToList
    listToAttrs
    nameValuePair
    ;
  inherit (lib.strings) concatStringsSep;
  inherit (lib) types;

  cfg = config.services.rauc;
  format = pkgs.formats.ini { };

  mountDir = "${cfg.dataDir}/mnt";

  mkSlot =
    slot:
    if slot.enable then
      slot.settings
      // {
        inherit (slot) device type;
      }
    else
      null;

  slotSections = listToAttrs (
    filter (slot: slot != null) (
      flatten (
        mapAttrsToList (
          name: indexes: imap0 (idx: slot: nameValuePair "slot.${name}.${toString idx}" (mkSlot slot)) indexes
        ) cfg.slots
      )
    )
  );

  configFile = format.generate "rauc.conf" (
    recursiveUpdate cfg.settings (
      recursiveUpdate {
        system = {
          inherit (cfg) compatible bootloader;
          bundle-formats = concatStringsSep " " cfg.bundleFormats;
          data-directory = cfg.dataDir;
          mountprefix = mountDir;
        };
      } slotSections
    )
  );
in
{
  options = {
    services.rauc = {
      enable = mkEnableOption "RAUC A/B update service";
      package = mkPackageOption pkgs "rauc" { };

      bootloader = mkOption {
        description = "The bootloader backend for RAUC.";
        example = "grub";

        type = types.enum [
          "barebox"
          "grub"
          "uboot"
          "efi"
          "custom"
          "noop"
        ];
      };

      bundleFormats = mkOption {
        default = [
          "-plain"
          "+verity"
        ];

        description = "Allowable formats for the RAUC bundle.";

        example = [
          "-plain"
          "+verity"
        ];

        type = with types; listOf str;
      };

      client.enable = mkEnableOption "RAUC client in the system environment";

      compatible = mkOption {
        description = "The compatibility string for this system. Can be any format so long as you are consistent.";
        example = "nix/appliance/foo";
        type = types.str;
      };

      dataDir = mkOption {
        default = "/var/lib/rauc";
        description = "The state directory for RAUC.";
        type = types.path;
      };

      mark-good.enable = mkEnableOption "RAUC Good-marking service";

      settings = mkOption {
        default = { };

        description = ''
          Rauc configuration that will be converted to INI. Refer to:
          <https://rauc.readthedocs.io/en/latest/reference.html#sec-ref-slot-config>
          for details on supported values.

          All module-specific options override these.
        '';

        type = format.type;
      };

      slots = mkOption {
        default = { };
        description = "RAUC slot definitions. Every key is a slot class and every value is a list of slot indexes.";

        type = types.attrsOf (
          types.listOf (
            types.submodule {
              options = {
                enable = mkEnableOption "this RAUC slot";

                device = mkOption {
                  description = "The device to update.";
                  type = types.str;
                };

                settings = mkOption {
                  default = { };
                  description = "Settings for this slot.";
                  type = types.attrs;
                };

                type = mkOption {
                  default = "raw";
                  description = "The type of the device.";

                  type = types.enum [
                    "raw"
                    "nand"
                    "nor"
                    "ubivol"
                    "ubifs"
                    "ext4"
                    "vfat"
                  ];
                };
              };
            }
          )
        );
      };
    };
  };

  config = mkMerge [
    (mkIf cfg.enable {
      systemd.services.rauc = {
        after = [
          "dbus.service"
        ];

        description = "RAUC Update Service";
        documentation = [ "https://rauc.readthedocs.io" ];

        serviceConfig = {
          BusName = "de.pengutronix.rauc";
          ExecStart = "${lib.getExe cfg.package} --conf=${configFile} --mount=/run/rauc/mnt service";
          MountFlags = "slave";
          RuntimeDirectory = "rauc/mnt";
          StateDirectory = baseNameOf cfg.dataDir;
          Type = "dbus";
          WorkingDirectory = cfg.dataDir;
        };

        wantedBy = [ "multi-user.target" ];
        wants = [ "basic.target" ];
      };

      systemd.tmpfiles.rules = [
        "d ${cfg.dataDir} 0750 root root - -"
        "d ${mountDir} 0750 root root - -"
      ];
    })
    (mkIf (cfg.enable && cfg.client.enable) {
      environment.systemPackages = [ cfg.package ];
      services.dbus.packages = [ cfg.package ];
    })
    (mkIf (cfg.enable && cfg.mark-good.enable) {
      systemd.services.rauc-mark-good = {
        after = [
          "rauc.service"
          "multi-user.target"
        ];

        description = "RAUC Good-marking service";
        documentation = [ "https://rauc.readthedocs.io" ];

        serviceConfig = {
          ExecStart = "${lib.getExe cfg.package} --conf=${configFile} status mark-good";
          Type = "oneshot";
        };

        wantedBy = [ "multi-user.target" ];
      };
    })
  ];

  meta.maintainers = with lib.maintainers; [ numinit ];
}

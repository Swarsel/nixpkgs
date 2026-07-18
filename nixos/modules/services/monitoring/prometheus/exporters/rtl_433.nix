{
  config,
  lib,
  pkgs,
  options,
  ...
}:

let
  cfg = config.services.prometheus.exporters.rtl_433;
in
{
  extraOpts =
    let
      mkMatcherOptionType =
        field: description:
        with lib.types;
        listOf (submodule {
          options = {
            "${field}" = lib.mkOption {
              description = description;
              type = int;
            };

            location = lib.mkOption {
              description = "Location to match.";
              type = str;
            };

            name = lib.mkOption {
              description = "Name to match.";
              type = str;
            };
          };
        });
    in
    {
      channels = lib.mkOption {
        default = [ ];

        description = ''
          List of channel matchers to export.
        '';

        example = [
          {
            channel = 6543;
            location = "Kitchen";
            name = "Acurite";
          }
        ];

        type = mkMatcherOptionType "channel" "Channel to match.";
      };

      ids = lib.mkOption {
        default = [ ];

        description = ''
          List of ID matchers to export.
        '';

        example = [
          {
            id = 1;
            location = "Bedroom";
            name = "Nexus";
          }
        ];

        type = mkMatcherOptionType "id" "ID to match.";
      };

      rtl433Flags = lib.mkOption {
        default = "-C si";

        description = ''
          Flags passed verbatim to rtl_433 binary.
          Having `-C si` (the default) is recommended since only Celsius temperatures are parsed.
        '';

        example = "-C si -R 19";
        type = lib.types.str;
      };
    };

  port = 9550;

  serviceOpts = {
    serviceConfig = {
      DeviceAllow = lib.mkForce "char-usb_device rw";

      ExecStart =
        let
          matchers =
            (map (m: "--channel_matcher '${m.name},${toString m.channel},${m.location}'") cfg.channels)
            ++ (map (m: "--id_matcher '${m.name},${toString m.id},${m.location}'") cfg.ids);
        in
        ''
          ${pkgs.prometheus-rtl_433-exporter}/bin/rtl_433_prometheus \
            -listen ${cfg.listenAddress}:${toString cfg.port} \
            -subprocess "${pkgs.rtl_433}/bin/rtl_433 -F json ${cfg.rtl433Flags}" \
            ${lib.concatStringsSep " \\\n  " matchers} \
            ${lib.concatStringsSep " \\\n  " cfg.extraFlags}
        '';

      # rtl_433 needs rw access to the USB radio.
      PrivateDevices = lib.mkForce false;
      RestrictAddressFamilies = [ "AF_NETLINK" ];
      # rtl-sdr udev rules make supported USB devices +rw by plugdev.
      SupplementaryGroups = "plugdev";
    };
  };
}

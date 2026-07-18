{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.hardware.printers;

  ensurePrinter =
    p:
    let
      args = lib.cli.toCommandLineShellGNU { } (
        {
          m = p.model;
          p = p.name;
          v = p.deviceUri;
        }
        // lib.optionalAttrs (p.location != null) {
          L = p.location;
        }
        // lib.optionalAttrs (p.description != null) {
          D = p.description;
        }
        // lib.optionalAttrs (p.ppdOptions != { }) {
          o = lib.mapAttrsToList (name: value: "${name}=${value}") p.ppdOptions;
        }
      );
    in
    ''
      # shellcheck disable=SC2016
      ${pkgs.cups}/bin/lpadmin ${args} -E
    '';

  ensureDefaultPrinter = name: ''
    ${pkgs.cups}/bin/lpadmin -d '${name}'
  '';

  # "graph but not # or /" can't be implemented as regex alone due to missing lookahead support
  noInvalidChars = str: lib.all (c: c != "#" && c != "/") (lib.stringToCharacters str);
  printerName = (lib.types.addCheck (lib.types.strMatching "[[:graph:]]+") noInvalidChars) // {
    description = "printable string without spaces, # and /";
  };

in
{
  options = {
    hardware.printers = {
      ensureDefaultPrinter = lib.mkOption {
        default = null;

        description = ''
          Ensures the named printer is the default CUPS printer / printer queue.
        '';

        type = lib.types.nullOr printerName;
      };

      ensurePrinters = lib.mkOption {
        default = [ ];

        description = ''
          Will regularly ensure that the given CUPS printers are configured as declared here.
          If a printer's options are manually changed afterwards, they will be overwritten eventually.
          This option will never delete any printer, even if removed from this list.
          You can check existing printers with {command}`lpstat -s`
          and remove printers with {command}`lpadmin -x <printer-name>`.
          Printers not listed here can still be manually configured.
        '';

        type = lib.types.listOf (
          lib.types.submodule {
            options = {
              description = lib.mkOption {
                default = null;

                description = ''
                  Optional human-readable description.
                '';

                example = "Brother HL-5140";
                type = lib.types.nullOr lib.types.str;
              };

              deviceUri = lib.mkOption {
                description = ''
                  How to reach the printer.
                  {command}`lpinfo -v` shows a list of supported device URIs and schemes.
                '';

                example = lib.literalExpression ''
                  "ipp://printserver.local/printers/BrotherHL_Workroom"
                  "usb://HP/DESKJET%20940C?serial=CN16E6C364BH"
                '';

                type = lib.types.str;
              };

              location = lib.mkOption {
                default = null;

                description = ''
                  Optional human-readable location.
                '';

                example = "Workroom";
                type = lib.types.nullOr lib.types.str;
              };

              model = lib.mkOption {
                description = ''
                  Location of the ppd driver file for the printer.
                  {command}`lpinfo -m` shows a list of supported models.
                '';

                example = lib.literalExpression ''
                  "gutenprint.''${lib.versions.majorMinor (lib.getVersion pkgs.gutenprint)}://brother-hl-5140/expert"
                '';

                type = lib.types.str;
              };

              name = lib.mkOption {
                description = ''
                  Name of the printer / printer queue.
                  May contain any printable characters except "/", "#", and space.
                '';

                example = "BrotherHL_Workroom";
                type = printerName;
              };

              ppdOptions = lib.mkOption {
                default = { };

                description = ''
                  Sets PPD options for the printer.
                  {command}`lpoptions [-p printername] -l` shows supported PPD options for the given printer.
                '';

                example = {
                  Duplex = "DuplexNoTumble";
                  PageSize = "A4";
                };

                type = lib.types.attrsOf lib.types.str;
              };
            };
          }
        );
      };
    };
  };

  config = lib.mkIf (cfg.ensurePrinters != [ ] && config.services.printing.enable) {
    systemd.services.ensure-printers = {
      after = [ "cups.service" ];
      description = "Ensure NixOS-configured CUPS printers";

      script = lib.concatStringsSep "\n" [
        (lib.concatMapStrings ensurePrinter cfg.ensurePrinters)
        (lib.optionalString (cfg.ensureDefaultPrinter != null) (
          ensureDefaultPrinter cfg.ensureDefaultPrinter
        ))
        # Note: if cupsd is "stateless" the service can't be stopped,
        # otherwise the configuration will be wiped on the next start.
        (lib.optionalString (
          with config.services.printing; startWhenNeeded && !stateless
        ) "systemctl stop cups.service")
      ];

      serviceConfig = {
        RemainAfterExit = true;
        Type = "oneshot";
      };

      wantedBy = [ "multi-user.target" ];
      wants = [ "cups.service" ];
    };
  };
}

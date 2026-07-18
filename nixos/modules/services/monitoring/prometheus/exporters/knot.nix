{
  config,
  lib,
  pkgs,
  options,
  ...
}:

let
  cfg = config.services.prometheus.exporters.knot;
  inherit (lib)
    mkOption
    types
    literalExpression
    concatStringsSep
    ;
in
{
  extraOpts = {
    knotLibraryPath = mkOption {
      default = null;

      description = ''
        Path to the library of `knot-dns`.
      '';

      example = literalExpression ''"''${pkgs.knot-dns.out}/lib/libknot.so"'';
      type = types.nullOr types.str;
    };

    knotSocketPath = mkOption {
      default = "/run/knot/knot.sock";

      description = ''
        Socket path of {manpage}`knotd(8)`.
      '';

      type = types.str;
    };

    knotSocketTimeout = mkOption {
      default = 2000;

      description = ''
        Timeout in seconds.
      '';

      type = types.ints.positive;
    };
  };

  port = 9433;

  serviceOpts = {
    path = with pkgs; [
      procps
    ];

    serviceConfig = {
      ExecStart = ''
        ${pkgs.prometheus-knot-exporter}/bin/knot-exporter \
          --web-listen-addr ${cfg.listenAddress} \
          --web-listen-port ${toString cfg.port} \
          --knot-socket-path ${cfg.knotSocketPath} \
          --knot-socket-timeout ${toString cfg.knotSocketTimeout} \
          ${lib.optionalString (cfg.knotLibraryPath != null) "--knot-library-path ${cfg.knotLibraryPath}"} \
          ${concatStringsSep " \\\n  " cfg.extraFlags}
      '';

      RestrictAddressFamilies = [
        # Need AF_UNIX to collect data
        "AF_UNIX"
      ];

      SupplementaryGroups = [
        "knot"
      ];
    };
  };
}

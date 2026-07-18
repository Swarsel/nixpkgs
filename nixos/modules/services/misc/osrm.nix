{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.osrm;
in

{
  options.services.osrm = {
    enable = lib.mkOption {
      default = false;
      description = "Enable the OSRM service.";
      type = lib.types.bool;
    };

    address = lib.mkOption {
      default = "0.0.0.0";
      description = "IP address on which the web server will listen.";
      type = lib.types.str;
    };

    algorithm = lib.mkOption {
      default = "MLD";
      description = "Algorithm to use for the data. Must be one of CH, CoreCH, MLD";

      type = lib.types.enum [
        "CH"
        "CoreCH"
        "MLD"
      ];
    };

    dataFile = lib.mkOption {
      description = "Data file location";
      example = "/var/lib/osrm/berlin-latest.osrm";
      type = lib.types.path;
    };

    extraFlags = lib.mkOption {
      default = [ ];
      description = "Extra command line arguments passed to osrm-routed";

      example = [
        "--max-table-size 1000"
        "--max-matching-size 1000"
      ];

      type = lib.types.listOf lib.types.str;
    };

    port = lib.mkOption {
      default = 5000;
      description = "Port on which the web server will run.";
      type = lib.types.port;
    };

    threads = lib.mkOption {
      default = 4;
      description = "Number of threads to use.";
      type = lib.types.int;
    };

  };

  config = lib.mkIf cfg.enable {

    systemd.services.osrm = {
      after = [ "network.target" ];
      description = "OSRM service";

      serviceConfig = {
        ExecStart = ''
          ${pkgs.osrm-backend}/bin/osrm-routed \
            --ip ${cfg.address} \
            --port ${toString cfg.port} \
            --threads ${toString cfg.threads} \
            --algorithm ${cfg.algorithm} \
            ${toString cfg.extraFlags} \
            ${cfg.dataFile}
        '';

        User = config.users.users.osrm.name;
      };

      wantedBy = [ "multi-user.target" ];
    };

    users.groups.osrm = { };

    users.users.osrm = {
      createHome = false;
      description = "OSRM user";
      group = config.users.users.osrm.name;
      isSystemUser = true;
    };
  };
}

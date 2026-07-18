{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.journalbeat;

  journalbeatYml = pkgs.writeText "journalbeat.yml" ''
    name: ${cfg.name}
    tags: ${builtins.toJSON cfg.tags}

    ${cfg.extraConfig}
  '';

in
{
  options = {

    services.journalbeat = {

      enable = lib.mkEnableOption "journalbeat";
      package = lib.mkPackageOption pkgs "journalbeat" { };

      extraConfig = lib.mkOption {
        default = "";
        description = "Any other configuration options you want to add";
        type = lib.types.lines;
      };

      name = lib.mkOption {
        default = "journalbeat";
        description = "Name of the beat";
        type = lib.types.str;
      };

      stateDir = lib.mkOption {
        default = "journalbeat";

        description = ''
          Directory below `/var/lib/` to store journalbeat's
          own logs and other data. This directory will be created automatically
          using systemd's StateDirectory mechanism.
        '';

        type = lib.types.str;
      };

      tags = lib.mkOption {
        default = [ ];
        description = "Tags to place on the shipped log messages";
        type = lib.types.listOf lib.types.str;
      };

    };
  };

  config = lib.mkIf cfg.enable {

    assertions = [
      {
        assertion = !lib.hasPrefix "/" cfg.stateDir;

        message =
          "The option services.journalbeat.stateDir shouldn't be an absolute directory."
          + " It should be a directory relative to /var/lib/.";
      }
    ];

    systemd.services.journalbeat = {
      after = [ "elasticsearch.service" ];
      description = "Journalbeat log shipper";

      serviceConfig = {
        ExecStart = ''
          ${cfg.package}/bin/journalbeat \
            -c ${journalbeatYml} \
            -path.data /var/lib/${cfg.stateDir}/data \
            -path.logs /var/lib/${cfg.stateDir}/logs'';

        ExecStartPre = [
          "${lib.getExe' pkgs.coreutils "mkdir"} -p ${cfg.stateDir}/data"
          "${lib.getExe' pkgs.coreutils "mkdir"} -p ${cfg.stateDir}/logs"
        ];

        Restart = "always";
        StateDirectory = cfg.stateDir;
      };

      wantedBy = [ "multi-user.target" ];
      wants = [ "elasticsearch.service" ];
    };
  };
}

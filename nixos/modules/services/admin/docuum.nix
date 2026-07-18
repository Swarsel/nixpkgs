{
  config,
  lib,
  pkgs,
  utils,
  ...
}:

let
  cfg = config.services.docuum;
  inherit (lib)
    mkIf
    mkEnableOption
    mkOption
    getExe
    types
    optionals
    concatMap
    ;
in
{
  options.services.docuum = {
    enable = mkEnableOption "docuum daemon";

    deletionChunkSize = mkOption {
      default = 1;
      description = "Removes specified quantity of images at a time.";
      example = 10;
      type = types.int;
    };

    keep = mkOption {
      default = [ ];
      description = "Prevents deletion of images for which repository:tag matches the specified regex.";
      example = [ "^my-image" ];
      type = types.listOf types.str;
    };

    minAge = mkOption {
      default = null;
      description = "Sets the minimum age of images to be considered for deletion.";
      example = "1d";
      type = types.nullOr types.str;
    };

    threshold = mkOption {
      default = "10 GB";
      description = "Threshold for deletion in bytes, like `10 GB`, `10 GiB`, `10GB` or percentage-based thresholds like `50%`";
      example = "50%";
      type = types.str;
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = config.virtualisation.docker.enable;
        message = "docuum requires docker on the host";
      }
    ];

    systemd.services.docuum = {
      after = [ "docker.socket" ];
      environment.HOME = "/var/lib/docuum";
      path = [ config.virtualisation.docker.package ];
      requires = [ "docker.socket" ];

      serviceConfig = {
        DynamicUser = true;

        ExecStart = utils.escapeSystemdExecArgs (
          [
            (getExe pkgs.docuum)
            "--threshold"
            cfg.threshold
            "--deletion-chunk-size"
            cfg.deletionChunkSize
          ]
          ++ (concatMap (keep: [
            "--keep"
            keep
          ]) cfg.keep)
          ++ (optionals (cfg.minAge != null) [
            "--min-age"
            cfg.minAge
          ])
        );

        StateDirectory = "docuum";
        SupplementaryGroups = [ "docker" ];
      };

      wantedBy = [ "multi-user.target" ];
    };
  };
}

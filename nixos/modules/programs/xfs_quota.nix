# Configuration for the xfs_quota command

{
  config,
  lib,
  pkgs,
  ...
}:

let

  cfg = config.programs.xfs_quota;

  limitOptions =
    opts:
    builtins.concatStringsSep " " [
      (lib.optionalString (opts.sizeSoftLimit != null) "bsoft=${opts.sizeSoftLimit}")
      (lib.optionalString (opts.sizeHardLimit != null) "bhard=${opts.sizeHardLimit}")
    ];

in

{

  ###### interface

  options = {

    programs.xfs_quota = {
      projects = lib.mkOption {
        default = { };
        description = "Setup of xfs_quota projects. Make sure the filesystem is mounted with the pquota option.";

        example = {
          projname = {
            id = 50;
            path = "/xfsprojects/projname";
            sizeHardLimit = "50g";
          };
        };

        type = lib.types.attrsOf (
          lib.types.submodule {
            options = {
              fileSystem = lib.mkOption {
                default = "/";
                description = "XFS filesystem hosting the xfs_quota project.";
                type = lib.types.str;
              };

              id = lib.mkOption {
                description = "Project ID.";
                type = lib.types.int;
              };

              path = lib.mkOption {
                description = "Project directory.";
                type = lib.types.str;
              };

              sizeHardLimit = lib.mkOption {
                default = null;
                description = "Hard limit of the project size.";
                example = "50g";
                type = lib.types.nullOr lib.types.str;
              };

              sizeSoftLimit = lib.mkOption {
                default = null;
                description = "Soft limit of the project size";
                example = "30g";
                type = lib.types.nullOr lib.types.str;
              };
            };
          }
        );
      };
    };

  };

  ###### implementation

  config = lib.mkIf (cfg.projects != { }) {

    environment.etc.projects.source = pkgs.writeText "etc-project" (
      builtins.concatStringsSep "\n" (
        lib.mapAttrsToList (name: opts: "${toString opts.id}:${opts.path}") cfg.projects
      )
    );

    environment.etc.projid.source = pkgs.writeText "etc-projid" (
      builtins.concatStringsSep "\n" (
        lib.mapAttrsToList (name: opts: "${name}:${toString opts.id}") cfg.projects
      )
    );

    systemd.services = lib.mapAttrs' (
      name: opts:
      lib.nameValuePair "xfs_quota-${name}" {
        after = [ ((builtins.replaceStrings [ "/" ] [ "-" ] opts.fileSystem) + ".mount") ];
        description = "Setup xfs_quota for project ${name}";
        restartTriggers = [ config.environment.etc.projects.source ];

        script = ''
          ${pkgs.xfsprogs.bin}/bin/xfs_quota -x -c 'project -s ${name}' ${opts.fileSystem}
          ${pkgs.xfsprogs.bin}/bin/xfs_quota -x -c 'limit -p ${limitOptions opts} ${name}' ${opts.fileSystem}
        '';

        serviceConfig = {
          RemainAfterExit = true;
          Type = "oneshot";
        };

        wantedBy = [ "multi-user.target" ];
      }
    ) cfg.projects;

  };

}

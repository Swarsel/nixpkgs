{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib)
    mkEnableOption
    mkPackageOption
    mkOption
    types
    mkIf
    maintainers
    ;

  cfg = config.security.isolate;
  configFile = pkgs.writeText "isolate-config.cf" ''
    box_root=${cfg.boxRoot}
    lock_root=${cfg.lockRoot}
    cg_root=${cfg.cgRoot}
    first_uid=${toString cfg.firstUid}
    first_gid=${toString cfg.firstGid}
    num_boxes=${toString cfg.numBoxes}
    restricted_init=${if cfg.restrictedInit then "1" else "0"}
    ${cfg.extraConfig}
  '';
  isolate = pkgs.symlinkJoin {
    name = "isolate-wrapped-${pkgs.isolate.version}";
    nativeBuildInputs = [ pkgs.makeWrapper ];
    paths = [ pkgs.isolate ];

    postBuild = ''
      wrapProgram $out/bin/isolate \
        --set ISOLATE_CONFIG_FILE ${configFile}

      wrapProgram $out/bin/isolate-cg-keeper \
        --set ISOLATE_CONFIG_FILE ${configFile}
    '';
  };
in
{
  options.security.isolate = {
    enable = mkEnableOption ''
      Sandbox for securely executing untrusted programs
    '';

    package = mkPackageOption pkgs "isolate-unwrapped" { };

    boxRoot = mkOption {
      default = "/var/lib/isolate/boxes";

      description = ''
        All sandboxes are created under this directory.
        To avoid symlink attacks, this directory and all its ancestors
        must be writeable only by root.
      '';

      type = types.path;
    };

    cgRoot = mkOption {
      default = "auto:/run/isolate/cgroup";

      description = ''
        Control group which subgroups are placed under.
        Either an explicit path to a subdirectory in cgroupfs, or "auto:file" to read
        the path from "file", where it is put by `isolate-cg-helper`.
      '';

      type = types.str;
    };

    extraConfig = mkOption {
      default = "";

      description = ''
        Extra configuration to append to the configuration file.
      '';

      type = types.str;
    };

    firstGid = mkOption {
      default = 60000;

      description = ''
        Start of block of GIDs reserved for sandboxes.
      '';

      type = types.numbers.between 1000 65533;
    };

    firstUid = mkOption {
      default = 60000;

      description = ''
        Start of block of UIDs reserved for sandboxes.
      '';

      type = types.numbers.between 1000 65533;
    };

    lockRoot = mkOption {
      default = "/run/isolate/locks";

      description = ''
        Directory where lock files are created.
      '';

      type = types.path;
    };

    numBoxes = mkOption {
      default = 1000;

      description = ''
        Number of UIDs and GIDs to reserve, starting from
        {option}`firstUid` and {option}`firstGid`.
      '';

      type = types.numbers.between 1000 65533;
    };

    restrictedInit = mkOption {
      default = false;

      description = ''
        If true, only root can create sandboxes.
      '';

      type = types.bool;
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [
      isolate
    ];

    systemd.services.isolate = {
      description = "Isolate control group hierarchy daemon";
      documentation = [ "man:isolate(1)" ];

      serviceConfig = {
        Delegate = true;
        ExecStart = "${isolate}/bin/isolate-cg-keeper";
        Slice = "isolate.slice";
        Type = "notify";
      };

      wantedBy = [ "multi-user.target" ];
    };

    systemd.slices.isolate = {
      description = "Isolate Sandbox Slice";
    };
  };

  meta.maintainers = with maintainers; [ virchau13 ];
}

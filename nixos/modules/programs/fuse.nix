{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.fuse;
in
{
  options.programs.fuse = {
    enable = lib.mkEnableOption "fuse";

    mountMax = lib.mkOption {
      default = 1000;

      description = ''
        Set the maximum number of FUSE mounts allowed to non-root users.
      '';

      # In the C code it's an "int" (i.e. signed and at least 16 bit), but
      # negative numbers obviously make no sense:
      type = lib.types.ints.between 0 32767; # 2^15 - 1
    };

    userAllowOther = lib.mkOption {
      default = false;

      description = ''
        Allow non-root users to specify the allow_other or allow_root mount
        options, see mount.fuse3(8).
      '';

      type = lib.types.bool;
    };
  };

  config = lib.mkIf cfg.enable {
    environment.etc."fuse.conf".text = ''
      ${lib.optionalString (!cfg.userAllowOther) "#"}user_allow_other
      mount_max = ${toString cfg.mountMax}
    '';

    environment.systemPackages = [
      pkgs.fuse
      pkgs.fuse3
    ];

    security.wrappers =
      let
        mkSetuidRoot = source: {
          inherit source;
          group = "root";
          owner = "root";
          setuid = true;
        };
      in
      {
        fusermount = mkSetuidRoot "${lib.getBin pkgs.fuse}/bin/fusermount";
        fusermount3 = mkSetuidRoot "${lib.getBin pkgs.fuse3}/bin/fusermount3";
      };

  };

  meta.maintainers = [ ];
}

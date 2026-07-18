{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.diod;

  diodBool = b: if b then "1" else "0";

in
{
  options = {
    services.diod = {
      enable = lib.mkOption {
        default = false;
        description = "Whether to enable the diod 9P file server.";
        type = lib.types.bool;
      };

      allsquash = lib.mkOption {
        default = true;

        description = ''
          Remap all users to "nobody". The attaching user need not be present in the
          password file.
        '';

        type = lib.types.bool;
      };

      authRequired = lib.mkOption {
        default = false;

        description = ''
          Allow clients to connect without authentication, i.e. without a valid MUNGE credential.
        '';

        type = lib.types.bool;
      };

      exportall = lib.mkOption {
        default = true;

        description = ''
          Export all file systems listed in /proc/mounts. If new file systems are mounted
          after diod has started, they will become immediately mountable. If there is a
          duplicate entry for a file system in the exports list, any options listed in
          the exports entry will apply.
        '';

        type = lib.types.bool;
      };

      exportopts = lib.mkOption {
        default = [ ];

        description = ''
          Establish a default set of export options. These are overridden, not appended
          to, by opts attributes in an "exports" entry.
        '';

        type = lib.types.listOf lib.types.str;
      };

      exports = lib.mkOption {
        default = [ ];

        description = ''
          List the file systems that clients will be allowed to mount. All paths should
          be fully qualified. The exports table can include two types of element:
          a string element (as above),
          or an alternate table element form { path="/path", opts="ro" }.
          In the alternate form, the (optional) opts attribute is a comma-separated list
          of export options. The two table element forms can be mixed in the exports
          table. Note that although diod will not traverse file system boundaries for a
          given mount due to inode uniqueness constraints, subdirectories of a file
          system can be separately exported.
        '';

        type = lib.types.listOf lib.types.str;
      };

      extraConfig = lib.mkOption {
        default = "";
        description = "Extra configuration options for diod.conf.";
        type = lib.types.lines;
      };

      listen = lib.mkOption {
        default = [ "0.0.0.0:564" ];

        description = ''
          [ "IP:PORT" [,"IP:PORT",...] ]
          List the interfaces and ports that diod should listen on.
        '';

        type = lib.types.listOf lib.types.str;
      };

      logdest = lib.mkOption {
        default = "syslog:daemon:err";

        description = ''
          Set the destination for logging.
          The value has the form of "syslog:facility:level" or "filename".
        '';

        type = lib.types.str;
      };

      nwthreads = lib.mkOption {
        default = 16;

        description = ''
          Sets the (fixed) number of worker threads created to handle 9P
          requests for a unique aname.
        '';

        type = lib.types.int;
      };

      squashuser = lib.mkOption {
        default = "nobody";

        description = ''
          Change the squash user. The squash user must be present in the password file.
        '';

        type = lib.types.str;
      };

      statfsPassthru = lib.mkOption {
        default = false;

        description = ''
          This option configures statfs to return the host file system's type
          rather than V9FS_MAGIC.
        '';

        type = lib.types.bool;
      };

      userdb = lib.mkOption {
        default = false;

        description = ''
          This option disables password/group lookups. It allows any uid to attach and
          assumes gid=uid, and supplementary groups contain only the primary gid.
        '';

        type = lib.types.bool;
      };
    };
  };

  config = lib.mkIf config.services.diod.enable {
    environment.etc."diod.conf".text = ''
      allsquash = ${diodBool cfg.allsquash}
      auth_required = ${diodBool cfg.authRequired}
      exportall = ${diodBool cfg.exportall}
      exportopts = "${lib.concatStringsSep "," cfg.exportopts}"
      exports = { ${lib.concatStringsSep ", " (map (s: ''"${s}"'') cfg.exports)} }
      listen = { ${lib.concatStringsSep ", " (map (s: ''"${s}"'') cfg.listen)} }
      logdest = "${cfg.logdest}"
      nwthreads = ${toString cfg.nwthreads}
      squashuser = "${cfg.squashuser}"
      statfs_passthru = ${diodBool cfg.statfsPassthru}
      userdb = ${diodBool cfg.userdb}
      ${cfg.extraConfig}
    '';

    environment.systemPackages = [ pkgs.diod ];
    systemd.packages = [ pkgs.diod ];
    systemd.services.diod.wantedBy = [ "multi-user.target" ];
  };
}

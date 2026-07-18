{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let

  cfg = config.services.atd;

  inherit (pkgs) at;

in

{

  ###### interface

  options = {

    services.atd.allowEveryone = mkOption {
      default = false;

      description = ''
        Whether to make {file}`/var/spool/at{jobs,spool}`
        writeable by everyone (and sticky).  This is normally not
        needed since the {command}`at` commands are
        setuid/setgid `atd`.
      '';

      type = types.bool;
    };

    services.atd.enable = mkOption {
      default = false;

      description = ''
        Whether to enable the {command}`at` daemon, a command scheduler.
      '';

      type = types.bool;
    };

  };

  ###### implementation

  config = mkIf cfg.enable {

    environment.systemPackages = [ at ];
    security.pam.services.atd = { };

    # Not wrapping "batch" because it's a shell script (kernel drops perms
    # anyway) and it's patched to invoke the "at" setuid wrapper.
    security.wrappers = builtins.listToAttrs (
      map
        (program: {
          name = "${program}";

          value = {
            group = "atd";
            owner = "atd";
            setgid = true;
            setuid = true;
            source = "${at}/bin/${program}";
          };
        })
        [
          "at"
          "atq"
          "atrm"
        ]
    );

    systemd.services.atd = {
      description = "Job Execution Daemon (atd)";
      documentation = [ "man:atd(8)" ];
      path = [ at ];

      preStart = ''
        # Snippets taken and adapted from the original `install' rule of
        # the makefile.

        # We assume these values are those actually used in Nixpkgs for
        # `at'.
        spooldir=/var/spool/atspool
        jobdir=/var/spool/atjobs
        etcdir=/etc/at

        install -dm755 -o atd -g atd "$etcdir"
        spool_and_job_dir_perms=${if cfg.allowEveryone then "1777" else "1770"}
        install -dm"$spool_and_job_dir_perms" -o atd -g atd "$spooldir" "$jobdir"
        if [ ! -f "$etcdir"/at.deny ]; then
            touch "$etcdir"/at.deny
            chown root:atd "$etcdir"/at.deny
            chmod 640 "$etcdir"/at.deny
        fi
        if [ ! -f "$jobdir"/.SEQ ]; then
            touch "$jobdir"/.SEQ
            chown atd:atd "$jobdir"/.SEQ
            chmod 600 "$jobdir"/.SEQ
        fi
      '';

      script = "atd";
      serviceConfig.Type = "forking";
      wantedBy = [ "multi-user.target" ];
    };

    users.groups.atd.gid = config.ids.gids.atd;

    users.users.atd = {
      description = "atd user";
      group = "atd";
      home = "/var/empty";
      uid = config.ids.uids.atd;
    };
  };
}

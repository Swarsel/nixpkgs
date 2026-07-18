{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.rethinkdb;
  rethinkdb = cfg.package;
in

{

  ###### interface

  options = {

    services.rethinkdb = {

      enable = lib.mkEnableOption "RethinkDB server";

      dbpath = lib.mkOption {
        default = "/var/db/rethinkdb";
        description = "Location where RethinkDB stores its data, 1 data directory per instance.";
      };

      group = lib.mkOption {
        default = "rethinkdb";
        description = "Group which rethinkdb user belongs to.";
      };

      pidpath = lib.mkOption {
        default = "/run/rethinkdb";
        description = "Location where each instance's pid file is located.";
      };

      #package = lib.mkOption {
      #  default = pkgs.rethinkdb;
      #  description = "Which RethinkDB derivation to use.";
      #};
      user = lib.mkOption {
        default = "rethinkdb";
        description = "User account under which RethinkDB runs.";
      };
      #cfgpath = lib.mkOption {
      #  default = "/etc/rethinkdb/instances.d";
      #  description = "Location where RethinkDB stores it config files, 1 config file per instance.";
      #};
      # TODO: currently not used by our implementation.
      #instances = lib.mkOption {
      #  type = lib.types.attrsOf lib.types.str;
      #  default = {};
      #  description = "List of named RethinkDB instances in our cluster.";
      #};

    };

  };

  ###### implementation
  config = lib.mkIf config.services.rethinkdb.enable {

    environment.systemPackages = [ rethinkdb ];

    systemd.services.rethinkdb = {
      after = [ "network.target" ];
      description = "RethinkDB server";

      preStart = ''
        if ! test -e ${cfg.dbpath}; then
            install -d -m0755 -o ${cfg.user} -g ${cfg.group} ${cfg.dbpath}
            install -d -m0755 -o ${cfg.user} -g ${cfg.group} ${cfg.dbpath}/default
            chown -R ${cfg.user}:${cfg.group} ${cfg.dbpath}
        fi
        if ! test -e "${cfg.pidpath}/default.pid"; then
            install -D -o ${cfg.user} -g ${cfg.group} /dev/null "${cfg.pidpath}/default.pid"
        fi
      '';

      serviceConfig = {
        ExecReload = "${pkgs.coreutils}/bin/kill -HUP $MAINPID";
        # TODO: abstract away 'default', which is a per-instance directory name
        #       allowing end user of this nix module to provide multiple instances,
        #       and associated directory per instance
        ExecStart = "${rethinkdb}/bin/rethinkdb -d ${cfg.dbpath}/default";
        Group = cfg.group;
        PIDFile = "${cfg.pidpath}/default.pid";
        PermissionsStartOnly = true;
        User = cfg.user;
      };

      wantedBy = [ "multi-user.target" ];
    };

    users.groups = lib.optionalAttrs (cfg.group == "rethinkdb") (
      lib.singleton {
        name = "rethinkdb";
      }
    );

    users.users.rethinkdb = lib.mkIf (cfg.user == "rethinkdb") {
      description = "RethinkDB server user";
      isSystemUser = true;
      name = "rethinkdb";
    };

  };

}

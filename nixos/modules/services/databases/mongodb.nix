{
  config,
  lib,
  pkgs,
  ...
}:
let

  cfg = config.services.mongodb;

  mongodb = cfg.package;

  mongoshExe = lib.getExe cfg.mongoshPackage;

  mongoCnf =
    cfg:
    pkgs.writeText "mongodb.conf" ''
      net.bindIp: ${cfg.bind_ip}
      ${lib.optionalString cfg.quiet "systemLog.quiet: true"}
      systemLog.destination: syslog
      storage.dbPath: ${cfg.dbpath}
      ${lib.optionalString cfg.enableAuth "security.authorization: enabled"}
      ${lib.optionalString (cfg.replSetName != "") "replication.replSetName: ${cfg.replSetName}"}
      ${cfg.extraConfig}
    '';

in

{
  imports = [
    (lib.mkRemovedOptionModule [
      "services"
      "mongodb"
      "initialRootPassword"
    ] "Use services.mongodb.initialRootPasswordFile to securely provide the initial root password.")
  ];

  ###### interface

  options = {

    services.mongodb = {

      enable = lib.mkEnableOption "the MongoDB server";

      package = lib.mkPackageOption pkgs "mongodb" {
        example = "pkgs.mongodb-ce";
      };

      bind_ip = lib.mkOption {
        default = "127.0.0.1";
        description = "IP to bind to";
        type = lib.types.str;
      };

      dbpath = lib.mkOption {
        default = "/var/db/mongodb";
        description = "Location where MongoDB stores its files";
        type = lib.types.str;
      };

      enableAuth = lib.mkOption {
        default = false;
        description = "Enable client authentication. Creates a default superuser with username root!";
        type = lib.types.bool;
      };

      extraConfig = lib.mkOption {
        default = "";
        description = "MongoDB extra configuration in YAML format";

        example = ''
          storage.journal.enabled: false
        '';

        type = lib.types.lines;
      };

      initialRootPasswordFile = lib.mkOption {
        default = null;
        description = "Path to the file containing the password for the root user if auth is enabled.";
        type = lib.types.nullOr lib.types.path;
      };

      initialScript = lib.mkOption {
        default = null;

        description = ''
          A file containing MongoDB statements to execute on first startup.
        '';

        type = lib.types.nullOr lib.types.path;
      };

      mongoshPackage = lib.mkPackageOption pkgs "mongosh" { };

      pidFile = lib.mkOption {
        default = "/run/mongodb.pid";
        description = "Location of MongoDB pid file";
        type = lib.types.str;
      };

      quiet = lib.mkOption {
        default = false;
        description = "quieter output";
        type = lib.types.bool;
      };

      replSetName = lib.mkOption {
        default = "";

        description = ''
          If this instance is part of a replica set, set its name here.
          Otherwise, leave empty to run as single node.
        '';

        type = lib.types.str;
      };

      user = lib.mkOption {
        default = "mongodb";
        description = "User account under which MongoDB runs";
        type = lib.types.str;
      };
    };

  };

  ###### implementation

  config = lib.mkIf config.services.mongodb.enable {
    assertions = [
      {
        assertion = !cfg.enableAuth || cfg.initialRootPasswordFile != null;
        message = "`enableAuth` requires `initialRootPasswordFile` to be set.";
      }
    ];

    systemd.services.mongodb = {
      after = [ "network.target" ];
      description = "MongoDB server";

      postStart = ''
        if test -e "${cfg.dbpath}/.first_startup"; then
          ${lib.optionalString (cfg.initialScript != null) ''
            ${lib.optionalString (cfg.enableAuth) "initialRootPassword=$(<${cfg.initialRootPasswordFile})"}
            ${mongoshExe} ${lib.optionalString (cfg.enableAuth) "-u root -p $initialRootPassword"} admin "${cfg.initialScript}"
          ''}
          rm -f "${cfg.dbpath}/.first_startup"
        fi
      '';

      preStart =
        let
          cfg_ = cfg // {
            bind_ip = "127.0.0.1";
            enableAuth = false;
          };
        in
        ''
          rm ${cfg.dbpath}/mongod.lock || true
          if ! test -e ${cfg.dbpath}; then
              install -d -m0700 -o ${cfg.user} ${cfg.dbpath}
          fi
          if ! test -e ${cfg.dbpath}/storage.bson; then
              # See postStart!
              touch ${cfg.dbpath}/.first_startup
          fi
          if ! test -e ${cfg.pidFile}; then
              install -D -o ${cfg.user} /dev/null ${cfg.pidFile}
          fi ''
        + lib.optionalString cfg.enableAuth ''

          if ! test -e "${cfg.dbpath}/.auth_setup_complete"; then
            systemd-run --unit=mongodb-for-setup --uid=${cfg.user} ${mongodb}/bin/mongod --config ${mongoCnf cfg_}
            # wait for mongodb
            while ! ${mongoshExe} --eval "db.version()" > /dev/null 2>&1; do sleep 0.1; done

            initialRootPassword=$(<${cfg.initialRootPasswordFile})
          ${mongoshExe} <<EOF
            use admin;
            db.createUser(
              {
                user: "root",
                pwd: "$initialRootPassword",
                roles: [
                  { role: "userAdminAnyDatabase", db: "admin" },
                  { role: "dbAdminAnyDatabase", db: "admin" },
                  { role: "readWriteAnyDatabase", db: "admin" }
                ]
              }
            )
          EOF
            touch "${cfg.dbpath}/.auth_setup_complete"
            systemctl stop mongodb-for-setup
          fi
        '';

      serviceConfig = {
        ExecStart = "${mongodb}/bin/mongod --config ${mongoCnf cfg} --fork --pidfilepath ${cfg.pidFile}";
        PIDFile = cfg.pidFile;
        PermissionsStartOnly = true;
        TimeoutStartSec = 120; # initial creating of journal can take some time
        Type = "forking";
        User = cfg.user;
      };

      wantedBy = [ "multi-user.target" ];
    };

    users.groups.mongodb = lib.mkIf (cfg.user == "mongodb") { };

    users.users.mongodb = lib.mkIf (cfg.user == "mongodb") {
      description = "MongoDB server user";
      group = "mongodb";
      isSystemUser = true;
      name = "mongodb";
    };

  };

}

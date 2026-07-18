{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.monetdb;

in
{
  ###### interface
  options = {
    services.monetdb = {

      enable = lib.mkEnableOption "the MonetDB database server";
      package = lib.mkPackageOption pkgs "monetdb" { };

      dataDir = lib.mkOption {
        default = "/var/lib/monetdb";
        description = "Data directory for the dbfarm.";
        type = lib.types.path;
      };

      group = lib.mkOption {
        default = "monetdb";
        description = "Group under which MonetDB runs.";
        type = lib.types.str;
      };

      listenAddress = lib.mkOption {
        default = "127.0.0.1";
        description = "Address to listen on.";
        example = "0.0.0.0";
        type = lib.types.str;
      };

      port = lib.mkOption {
        default = 50000;
        description = "Port to listen on.";
        type = lib.types.port;
      };

      user = lib.mkOption {
        default = "monetdb";
        description = "User account under which MonetDB runs.";
        type = lib.types.str;
      };
    };
  };

  ###### implementation
  config = lib.mkIf cfg.enable {

    environment.systemPackages = [ cfg.package ];

    systemd.services.monetdb = {
      after = [ "network.target" ];
      description = "MonetDB database server";
      path = [ cfg.package ];

      preStart = ''
        if [ ! -e ${cfg.dataDir}/.merovingian_properties ]; then
          # Create the dbfarm (as cfg.user)
          ${cfg.package}/bin/monetdbd create ${cfg.dataDir}
        fi

        # Update the properties
        ${cfg.package}/bin/monetdbd set port=${toString cfg.port} ${cfg.dataDir}
        ${cfg.package}/bin/monetdbd set listenaddr=${cfg.listenAddress} ${cfg.dataDir}
      '';

      serviceConfig = {
        ExecStart = "${cfg.package}/bin/monetdbd start -n ${cfg.dataDir}";
        ExecStop = "${cfg.package}/bin/monetdbd stop ${cfg.dataDir}";
        Group = cfg.group;
        User = cfg.user;
      };

      unitConfig.RequiresMountsFor = "${cfg.dataDir}";
      wantedBy = [ "multi-user.target" ];
    };

    users.groups.monetdb = lib.mkIf (cfg.group == "monetdb") {
      gid = config.ids.gids.monetdb;
      members = [ cfg.user ];
    };

    users.users.monetdb = lib.mkIf (cfg.user == "monetdb") {
      createHome = true;
      description = "MonetDB user";
      group = cfg.group;
      home = cfg.dataDir;
      uid = config.ids.uids.monetdb;
    };

  };

  meta.maintainers = with lib.maintainers; [ StillerHarpo ];
}

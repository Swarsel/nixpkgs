{
  config,
  lib,
  pkgs,
  options,
  ...
}:

with lib;

let
  cfg = config.services.quassel;
  opt = options.services.quassel;
  quassel = cfg.package;
  user = if cfg.user != null then cfg.user else "quassel";
in

{

  ###### interface

  options = {

    services.quassel = {

      enable = mkEnableOption "the Quassel IRC client daemon";
      package = mkPackageOption pkgs "quasselDaemon" { };

      certificateFile = mkOption {
        default = null;

        description = ''
          Path to the certificate used for SSL connections with clients.
        '';

        type = types.nullOr types.str;
      };

      dataDir = mkOption {
        default = "/home/${user}/.config/quassel-irc.org";

        defaultText = literalExpression ''
          "/home/''${config.${opt.user}}/.config/quassel-irc.org"
        '';

        description = ''
          The directory holding configuration files, the SQlite database and the SSL Cert.
        '';

        type = types.str;
      };

      interfaces = mkOption {
        default = [ "127.0.0.1" ];

        description = ''
          The interfaces the Quassel daemon will be listening to.  If `[ 127.0.0.1 ]`,
          only clients on the local host can connect to it; if `[ 0.0.0.0 ]`, clients
          can access it from any network interface.
        '';

        type = types.listOf types.str;
      };

      portNumber = mkOption {
        default = 4242;

        description = ''
          The port number the Quassel daemon will be listening to.
        '';

        type = types.port;
      };

      requireSSL = mkOption {
        default = false;

        description = ''
          Require SSL for connections from clients.
        '';

        type = types.bool;
      };

      user = mkOption {
        default = null;

        description = ''
          The existing user the Quassel daemon should run as. If left empty, a default "quassel" user will be created.
        '';

        type = types.nullOr types.str;
      };

    };

  };

  ###### implementation

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.requireSSL -> cfg.certificateFile != null;
        message = "Quassel needs a certificate file in order to require SSL";
      }
    ];

    systemd.services.quassel = {
      after = [
        "network.target"
      ]
      ++ optional config.services.postgresql.enable "postgresql.target"
      ++ optional config.services.mysql.enable "mysql.service";

      description = "Quassel IRC client daemon";

      serviceConfig = {
        ExecStart = concatStringsSep " " (
          [
            "${quassel}/bin/quasselcore"
            "--listen=${concatStringsSep "," cfg.interfaces}"
            "--port=${toString cfg.portNumber}"
            "--configdir=${cfg.dataDir}"
          ]
          ++ optional cfg.requireSSL "--require-ssl"
          ++ optional (cfg.certificateFile != null) "--ssl-cert=${cfg.certificateFile}"
        );

        User = user;
      };

      wantedBy = [ "multi-user.target" ];
    };

    systemd.tmpfiles.rules = [
      "d '${cfg.dataDir}' - ${user} - - -"
    ];

    users.groups = optionalAttrs (cfg.user == null) {
      quassel = {
        gid = config.ids.gids.quassel;
        name = "quassel";
      };
    };

    users.users = optionalAttrs (cfg.user == null) {
      quassel = {
        description = "Quassel IRC client daemon";
        group = "quassel";
        name = "quassel";
        uid = config.ids.uids.quassel;
      };
    };

  };

}

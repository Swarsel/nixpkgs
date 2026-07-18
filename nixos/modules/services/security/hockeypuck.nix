{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.hockeypuck;
  settingsFormat = pkgs.formats.toml { };
in
{
  options.services.hockeypuck = {
    enable = lib.mkEnableOption "Hockeypuck OpenPGP Key Server";

    port = lib.mkOption {
      default = 11371;
      description = "HKP port to listen on.";
      type = lib.types.port;
    };

    settings = lib.mkOption {
      default = { };

      description = ''
        Configuration file for hockeypuck, here you can override
        certain settings (`loglevel` and
        `openpgp.db.dsn`) by just setting those values.

        For other settings you need to use lib.mkForce to override them.

        This service doesn't provision or enable postgres on your
        system, it rather assumes that you enable postgres and create
        the database yourself.

        Example:
        ```
          services.postgresql = {
            enable = true;
            ensureDatabases = [ "hockeypuck" ];
            ensureUsers = [{
              name = "hockeypuck";
              ensureDBOwnership = true;
            }];
          };
        ```
      '';

      example = lib.literalExpression ''
        {
          hockeypuck = {
            loglevel = "INFO";
            logfile = "/var/log/hockeypuck/hockeypuck.log";
            indexTemplate = "''${pkgs.hockeypuck-web}/share/templates/index.html.tmpl";
            vindexTemplate = "''${pkgs.hockeypuck-web}/share/templates/index.html.tmpl";
            statsTemplate = "''${pkgs.hockeypuck-web}/share/templates/stats.html.tmpl";
            webroot = "''${pkgs.hockeypuck-web}/share/webroot";

            hkp.bind = ":''${toString cfg.port}";

            openpgp.db = {
              driver = "postgres-jsonb";
              dsn = "database=hockeypuck host=/var/run/postgresql sslmode=disable";
            };
          };
        }
      '';

      type = settingsFormat.type;
    };
  };

  config = lib.mkIf cfg.enable {
    services.hockeypuck.settings.hockeypuck = {
      hkp.bind = ":${toString cfg.port}";
      indexTemplate = "${pkgs.hockeypuck-web}/share/templates/index.html.tmpl";
      logfile = "/var/log/hockeypuck/hockeypuck.log";
      loglevel = lib.mkDefault "INFO";

      openpgp.db = {
        driver = "postgres-jsonb";
        dsn = lib.mkDefault "database=hockeypuck host=/var/run/postgresql sslmode=disable";
      };

      statsTemplate = "${pkgs.hockeypuck-web}/share/templates/stats.html.tmpl";
      vindexTemplate = "${pkgs.hockeypuck-web}/share/templates/index.html.tmpl";
      webroot = "${pkgs.hockeypuck-web}/share/webroot";
    };

    systemd.services.hockeypuck = {
      after = [
        "network.target"
        "postgresql.target"
      ];

      description = "Hockeypuck OpenPGP Key Server";

      serviceConfig = {
        ExecStart = "${pkgs.hockeypuck}/bin/hockeypuck -config ${settingsFormat.generate "config.toml" cfg.settings}";
        LogsDirectory = "hockeypuck";
        LogsDirectoryMode = "0755";
        Restart = "always";
        RestartSec = "5s";
        StateDirectory = "hockeypuck";
        User = "hockeypuck";
        WorkingDirectory = "/var/lib/hockeypuck";
      };

      wantedBy = [ "multi-user.target" ];
    };

    users.groups.hockeypuck = { };

    users.users.hockeypuck = {
      description = "Hockeypuck user";
      group = "hockeypuck";
      isSystemUser = true;
    };
  };

  meta.maintainers = [ ];
}

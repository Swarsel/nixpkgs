{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.longview;

  runDir = "/run/longview";
  configsDir = "${runDir}/longview.d";

in
{
  options = {

    services.longview = {

      enable = lib.mkOption {
        default = false;

        description = ''
          If enabled, system metrics will be sent to Linode LongView.
        '';

        type = lib.types.bool;
      };

      apacheStatusUrl = lib.mkOption {
        default = "";

        description = ''
          The Apache status page URL. If provided, Longview will
          gather statistics from this location. This requires Apache
          mod_status to be loaded and enabled.
        '';

        example = "http://127.0.0.1/server-status";
        type = lib.types.str;
      };

      apiKey = lib.mkOption {
        default = "";

        description = ''
          Longview API key. To get this, look in Longview settings which
          are found at <https://manager.linode.com/longview/>.

          Warning: this secret is stored in the world-readable Nix store!
          Use {option}`apiKeyFile` instead.
        '';

        example = "01234567-89AB-CDEF-0123456789ABCDEF";
        type = lib.types.str;
      };

      apiKeyFile = lib.mkOption {
        default = null;

        description = ''
          A file containing the Longview API key.
          To get this, look in Longview settings which
          are found at <https://manager.linode.com/longview/>.

          {option}`apiKeyFile` takes precedence over {option}`apiKey`.
        '';

        example = "/run/keys/longview-api-key";
        type = lib.types.nullOr lib.types.path;
      };

      mysqlPassword = lib.mkOption {
        default = "";

        description = ''
          The password corresponding to {option}`mysqlUser`.
          Warning: this is stored in cleartext in the Nix store!
          Use {option}`mysqlPasswordFile` instead.
        '';

        type = lib.types.str;
      };

      mysqlPasswordFile = lib.mkOption {
        default = null;

        description = ''
          A file containing the password corresponding to {option}`mysqlUser`.
        '';

        example = "/run/keys/dbpassword";
        type = lib.types.nullOr lib.types.path;
      };

      mysqlUser = lib.mkOption {
        default = "";

        description = ''
          The user for connecting to the MySQL database. If provided,
          Longview will connect to MySQL and collect statistics about
          queries, etc. This user does not need to have been granted
          any extra privileges.
        '';

        type = lib.types.str;
      };

      nginxStatusUrl = lib.mkOption {
        default = "";

        description = ''
          The Nginx status page URL. Longview will gather statistics
          from this URL. This requires the Nginx stub_status module to
          be enabled and configured at the given location.
        '';

        example = "http://127.0.0.1/nginx_status";
        type = lib.types.str;
      };

    };

  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.apiKeyFile != null;
        message = "Longview needs an API key configured";
      }
    ];

    # Create API key file if not configured.
    services.longview.apiKeyFile = lib.mkIf (cfg.apiKey != "") (
      lib.mkDefault (
        toString (
          pkgs.writeTextFile {
            name = "longview.key";
            text = cfg.apiKey;
          }
        )
      )
    );

    # Create MySQL password file if not configured.
    services.longview.mysqlPasswordFile = lib.mkDefault (
      toString (
        pkgs.writeTextFile {
          name = "mysql-password-file";
          text = cfg.mysqlPassword;
        }
      )
    );

    systemd.services.longview = {
      after = [ "network.target" ];
      description = "Longview Metrics Collection";

      preStart = ''
        umask 077
        mkdir -p ${configsDir}
      ''
      + (lib.optionalString (cfg.apiKeyFile != null) ''
        cp --no-preserve=all "${cfg.apiKeyFile}" ${runDir}/longview.key
      '')
      + (lib.optionalString (cfg.apacheStatusUrl != "") ''
        cat > ${configsDir}/Apache.conf <<EOF
        location ${cfg.apacheStatusUrl}?auto
        EOF
      '')
      + (lib.optionalString (cfg.mysqlUser != "" && cfg.mysqlPasswordFile != null) ''
        cat > ${configsDir}/MySQL.conf <<EOF
        username ${cfg.mysqlUser}
        password `head -n1 "${cfg.mysqlPasswordFile}"`
        EOF
      '')
      + (lib.optionalString (cfg.nginxStatusUrl != "") ''
        cat > ${configsDir}/Nginx.conf <<EOF
        location ${cfg.nginxStatusUrl}
        EOF
      '');

      serviceConfig.ExecReload = "-${pkgs.coreutils}/bin/kill -HUP $MAINPID";
      serviceConfig.ExecStart = "${pkgs.longview}/bin/longview";
      serviceConfig.ExecStop = "-${pkgs.coreutils}/bin/kill -TERM $MAINPID";
      serviceConfig.PIDFile = "${runDir}/longview.pid";
      serviceConfig.Type = "forking";
      wantedBy = [ "multi-user.target" ];
    };

    warnings =
      let
        warn =
          k: lib.optional (cfg.${k} != "") "config.services.longview.${k} is insecure. Use ${k}File instead.";
      in
      lib.concatMap warn [
        "apiKey"
        "mysqlPassword"
      ];
  };
}

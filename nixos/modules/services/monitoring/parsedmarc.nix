{
  config,
  lib,
  pkgs,
  options,
  ...
}:

let
  cfg = config.services.parsedmarc;
  opt = options.services.parsedmarc;
  isSecret = v: isAttrs v && v ? _secret && isString v._secret;
  ini = pkgs.formats.ini {
    mkKeyValue = lib.flip lib.generators.mkKeyValueDefault "=" {
      mkValueString =
        v:
        if isInt v then
          toString v
        else if isString v then
          v
        else if true == v then
          "True"
        else if false == v then
          "False"
        else if isSecret v then
          hashString "sha256" v._secret
        else
          throw "unsupported type ${typeOf v}: ${(lib.generators.toPretty { }) v}";
    };
  };
  inherit (builtins)
    elem
    isAttrs
    isString
    isInt
    typeOf
    hashString
    ;
in
{
  options.services.parsedmarc = {

    enable = lib.mkEnableOption ''
      parsedmarc, a DMARC report monitoring service
    '';

    provision = {
      elasticsearch = lib.mkOption {
        default = true;

        description = ''
          Whether to set up and use a local instance of Elasticsearch.
        '';

        type = lib.types.bool;
      };

      geoIp = lib.mkOption {
        default = true;

        description = ''
          Whether to enable and configure the [geoipupdate](#opt-services.geoipupdate.enable)
          service to automatically fetch GeoIP databases. Not crucial,
          but recommended for full functionality.

          To finish the setup, you need to manually set the [](#opt-services.geoipupdate.settings.AccountID) and
          [](#opt-services.geoipupdate.settings.LicenseKey)
          options.
        '';

        type = lib.types.bool;
      };

      grafana = {
        dashboard = lib.mkOption {
          default = config.services.grafana.enable;
          defaultText = lib.literalExpression "config.services.grafana.enable";

          description = ''
            Whether the official parsedmarc grafana dashboard should
            be provisioned to the local grafana instance.
          '';

          type = lib.types.bool;
        };

        datasource = lib.mkOption {
          apply = x: x && cfg.provision.elasticsearch;
          default = cfg.provision.elasticsearch && config.services.grafana.enable;

          defaultText = lib.literalExpression ''
            config.${opt.provision.elasticsearch} && config.${options.services.grafana.enable}
          '';

          description = ''
            Whether the automatically provisioned Elasticsearch
            instance should be added as a grafana datasource. Has no
            effect unless
            [](#opt-services.parsedmarc.provision.elasticsearch)
            is also enabled.
          '';

          type = lib.types.bool;
        };
      };

      localMail = {
        enable = lib.mkOption {
          default = false;

          description = ''
            Whether Postfix and Dovecot should be set up to receive
            mail locally. parsedmarc will be configured to watch the
            local inbox as the automatically created user specified in
            [](#opt-services.parsedmarc.provision.localMail.recipientName)
          '';

          type = lib.types.bool;
        };

        hostname = lib.mkOption {
          default = config.networking.fqdn;
          defaultText = lib.literalExpression "config.networking.fqdn";

          description = ''
            The hostname to use when configuring Postfix.

            Should correspond to the host's fully qualified domain
            name and the domain part of the email address which
            receives DMARC reports. You also have to set up an MX record
            pointing to this domain name.
          '';

          example = "monitoring.example.com";
          type = lib.types.str;
        };

        recipientName = lib.mkOption {
          default = "dmarc";

          description = ''
            The DMARC mail recipient name, i.e. the name part of the
            email address which receives DMARC reports.

            A local user with this name will be set up and assigned a
            randomized password on service start.
          '';

          type = lib.types.str;
        };
      };
    };

    settings = lib.mkOption {
      description = ''
        Configuration parameters to set in
        {file}`parsedmarc.ini`. For a full list of
        available parameters, see
        <https://domainaware.github.io/parsedmarc/#configuration-file>.

        Settings containing secret data should be set to an attribute
        set containing the attribute `_secret` - a
        string pointing to a file containing the value the option
        should be set to. See the example to get a better picture of
        this: in the resulting {file}`parsedmarc.ini`
        file, the `splunk_hec.token` key will be set
        to the contents of the
        {file}`/run/keys/splunk_token` file.
      '';

      example = lib.literalExpression ''
        {
          imap = {
            host = "imap.example.com";
            user = "alice@example.com";
            password = { _secret = "/run/keys/imap_password" };
          };
          mailbox = {
            watch = true;
            batch_size = 30;
          };
          splunk_hec = {
            url = "https://splunkhec.example.com";
            token = { _secret = "/run/keys/splunk_token" };
            index = "email";
          };
        }
      '';

      type = lib.types.submodule {
        options = {
          elasticsearch = {
            cert_path = lib.mkOption {
              default = config.security.pki.caBundle;
              defaultText = lib.literalExpression "config.security.pki.caBundle";

              description = ''
                The path to a TLS certificate bundle used to verify
                the server's certificate.
              '';

              type = lib.types.path;
            };

            hosts = lib.mkOption {
              apply = x: if x == [ ] then null else lib.concatStringsSep "," x;
              default = [ ];

              description = ''
                A list of Elasticsearch hosts to push parsed reports
                to.
              '';

              type = with lib.types; listOf str;
            };

            password = lib.mkOption {
              apply = x: if isAttrs x || x == null then x else { _secret = x; };
              default = null;

              description = ''
                The password to use when connecting to Elasticsearch,
                if required.

                Always handled as a secret whether the value is
                wrapped in a `{ _secret = ...; }`
                attrset or not (refer to [](#opt-services.parsedmarc.settings) for
                details).
              '';

              type = with lib.types; nullOr (either path (attrsOf path));
            };

            ssl = lib.mkOption {
              default = false;

              description = ''
                Whether to use an encrypted SSL/TLS connection.
              '';

              type = lib.types.bool;
            };

            user = lib.mkOption {
              default = null;

              description = ''
                Username to use when connecting to Elasticsearch, if
                required.
              '';

              type = with lib.types; nullOr str;
            };
          };

          general = {
            save_aggregate = lib.mkOption {
              default = true;

              description = ''
                Save aggregate report data to Elasticsearch and/or Splunk.
              '';

              type = lib.types.bool;
            };

            save_forensic = lib.mkOption {
              default = true;

              description = ''
                Save forensic report data to Elasticsearch and/or Splunk.
              '';

              type = lib.types.bool;
            };
          };

          imap = {
            host = lib.mkOption {
              default = "localhost";

              description = ''
                The IMAP server hostname or IP address.
              '';

              type = lib.types.str;
            };

            password = lib.mkOption {
              apply = x: if isAttrs x || x == null then x else { _secret = x; };
              default = null;

              description = ''
                The IMAP server password.

                Always handled as a secret whether the value is
                wrapped in a `{ _secret = ...; }`
                attrset or not (refer to [](#opt-services.parsedmarc.settings) for
                details).
              '';

              type = with lib.types; nullOr (either path (attrsOf path));
            };

            port = lib.mkOption {
              default = 993;

              description = ''
                The IMAP server port.
              '';

              type = lib.types.port;
            };

            ssl = lib.mkOption {
              default = true;

              description = ''
                Use an encrypted SSL/TLS connection.
              '';

              type = lib.types.bool;
            };

            user = lib.mkOption {
              default = null;

              description = ''
                The IMAP server username.
              '';

              type = with lib.types; nullOr str;
            };
          };

          mailbox = {
            delete = lib.mkOption {
              default = false;

              description = ''
                Delete messages after processing them, instead of archiving them.
              '';

              type = lib.types.bool;
            };

            watch = lib.mkOption {
              default = true;

              description = ''
                Use the IMAP IDLE command to process messages as they arrive.
              '';

              type = lib.types.bool;
            };
          };

          smtp = {
            from = lib.mkOption {
              default = null;

              description = ''
                The `From` address to use for the
                outgoing mail.
              '';

              type = with lib.types; nullOr str;
            };

            host = lib.mkOption {
              default = null;

              description = ''
                The SMTP server hostname or IP address.
              '';

              type = with lib.types; nullOr str;
            };

            password = lib.mkOption {
              apply = x: if isAttrs x || x == null then x else { _secret = x; };
              default = null;

              description = ''
                The SMTP server password.

                Always handled as a secret whether the value is
                wrapped in a `{ _secret = ...; }`
                attrset or not (refer to [](#opt-services.parsedmarc.settings) for
                details).
              '';

              type = with lib.types; nullOr (either path (attrsOf path));
            };

            port = lib.mkOption {
              default = null;

              description = ''
                The SMTP server port.
              '';

              type = with lib.types; nullOr port;
            };

            ssl = lib.mkOption {
              default = null;

              description = ''
                Use an encrypted SSL/TLS connection.
              '';

              type = with lib.types; nullOr bool;
            };

            to = lib.mkOption {
              apply = x: if x == [ ] || x == null then null else lib.concatStringsSep "," x;
              default = null;

              description = ''
                The addresses to send outgoing mail to.
              '';

              type = with lib.types; nullOr (listOf str);
            };

            user = lib.mkOption {
              default = null;

              description = ''
                The SMTP server username.
              '';

              type = with lib.types; nullOr str;
            };
          };
        };

        freeformType = ini.type;

      };
    };

  };

  config = lib.mkIf cfg.enable {

    services.dovecot2 = lib.mkIf cfg.provision.localMail.enable {
      enable = true;
      protocols = [ "imap" ];
    };

    services.elasticsearch.enable = lib.mkDefault cfg.provision.elasticsearch;

    services.geoipupdate = lib.mkIf cfg.provision.geoIp {
      enable = true;

      settings = {
        DatabaseDirectory = "/var/lib/GeoIP";

        EditionIDs = [
          "GeoLite2-ASN"
          "GeoLite2-City"
          "GeoLite2-Country"
        ];
      };
    };

    services.grafana = {
      declarativePlugins =
        with pkgs.grafanaPlugins;
        lib.mkIf cfg.provision.grafana.dashboard [
          grafana-worldmap-panel
          grafana-piechart-panel
        ];

      provision = {
        enable = cfg.provision.grafana.datasource || cfg.provision.grafana.dashboard;

        dashboards.settings.providers = lib.mkIf cfg.provision.grafana.dashboard [
          {
            options.path = "${pkgs.parsedmarc.dashboard}";
            name = "parsedmarc";
          }
        ];

        datasources.settings.datasources =
          let
            esVersion = lib.getVersion config.services.elasticsearch.package;
          in
          lib.mkIf cfg.provision.grafana.datasource [
            {
              access = "proxy";

              jsonData = {
                inherit esVersion;
                timeField = "date_range";
              };

              name = "dmarc-ag";
              type = "elasticsearch";
              url = "http://localhost:9200";
            }
            {
              access = "proxy";

              jsonData = {
                inherit esVersion;
                timeField = "date_range";
              };

              name = "dmarc-fo";
              type = "elasticsearch";
              url = "http://localhost:9200";
            }
          ];
      };
    };

    services.parsedmarc.settings = lib.mkMerge [
      (lib.mkIf cfg.provision.elasticsearch {
        elasticsearch = {
          hosts = [ "http://localhost:9200" ];
          ssl = false;
        };
      })
      (lib.mkIf cfg.provision.localMail.enable {
        imap = {
          host = "localhost";
          password = "${pkgs.writeText "imap-password" "@imap-password@"}";
          port = 143;
          ssl = false;
          user = cfg.provision.localMail.recipientName;
        };

        mailbox = {
          watch = true;
        };
      })
    ];

    services.postfix = lib.mkIf cfg.provision.localMail.enable {
      enable = true;

      settings.main = {
        mydestination = cfg.provision.localMail.hostname;
        myhostname = cfg.provision.localMail.hostname;
        myorigin = cfg.provision.localMail.hostname;
      };
    };

    systemd.services.parsedmarc =
      let
        # Remove any empty attributes from the config, i.e. empty
        # lists, empty attrsets and null. This makes it possible to
        # list interesting options in `settings` without them always
        # ending up in the resulting config.
        filteredConfig = lib.converge (lib.filterAttrsRecursive (
          _: v:
          !elem v [
            null
            [ ]
            { }
          ]
        )) cfg.settings;

        # Extract secrets (attributes set to an attrset with a
        # "_secret" key) from the settings and generate the commands
        # to run to perform the secret replacements.
        secretPaths = lib.catAttrs "_secret" (lib.collect isSecret filteredConfig);
        parsedmarcConfig = ini.generate "parsedmarc.ini" filteredConfig;
        mkSecretReplacement = file: ''
          replace-secret ${
            lib.escapeShellArgs [
              (hashString "sha256" file)
              file
              "/run/parsedmarc/parsedmarc.ini"
            ]
          }
        '';
        secretReplacements = lib.concatMapStrings mkSecretReplacement secretPaths;
      in
      {
        after = [
          "postfix.service"
          "dovecot2.service"
          "elasticsearch.service"
        ];

        path = with pkgs; [
          replace-secret
          openssl
          shadow
        ];

        serviceConfig = {
          CapabilityBoundingSet = "";
          DynamicUser = true;
          ExecStart = "${lib.getExe pkgs.parsedmarc} -c /run/parsedmarc/parsedmarc.ini";

          ExecStartPre =
            let
              startPreFullPrivileges = ''
                set -o errexit -o pipefail -o nounset -o errtrace
                shopt -s inherit_errexit

                umask u=rwx,g=,o=
                cp ${parsedmarcConfig} /run/parsedmarc/parsedmarc.ini
                chown parsedmarc:parsedmarc /run/parsedmarc/parsedmarc.ini
                ${secretReplacements}
              ''
              + lib.optionalString cfg.provision.localMail.enable ''
                openssl rand -hex 64 >/run/parsedmarc/dmarc_user_passwd
                replace-secret '@imap-password@' '/run/parsedmarc/dmarc_user_passwd' /run/parsedmarc/parsedmarc.ini
                echo "Setting new randomized password for user '${cfg.provision.localMail.recipientName}'."
                cat <(echo -n "${cfg.provision.localMail.recipientName}:") /run/parsedmarc/dmarc_user_passwd | chpasswd
              '';
            in
            "+${pkgs.writeShellScript "parsedmarc-start-pre-full-privileges" startPreFullPrivileges}";

          Group = "parsedmarc";
          LockPersonality = true;
          MemoryDenyWriteExecute = true;
          PrivateDevices = true;
          PrivateMounts = true;
          PrivateUsers = true;
          ProcSubset = "pid";
          ProtectClock = true;
          ProtectControlGroups = true;
          ProtectHome = true;
          ProtectHostname = true;
          ProtectKernelLogs = true;
          ProtectKernelModules = true;
          ProtectKernelTunables = true;
          ProtectProc = "invisible";

          RestrictAddressFamilies = [
            "AF_UNIX"
            "AF_INET"
            "AF_INET6"
          ];

          RestrictNamespaces = true;
          RestrictRealtime = true;
          RuntimeDirectory = "parsedmarc";
          RuntimeDirectoryMode = "0700";
          SystemCallArchitectures = "native";

          SystemCallFilter = [
            "@system-service"
            "~@privileged"
            "~@resources"
          ];

          Type = "simple";
          User = "parsedmarc";
        };

        wantedBy = [ "multi-user.target" ];
      };

    users.users.${cfg.provision.localMail.recipientName} = lib.mkIf cfg.provision.localMail.enable {
      description = "DMARC mail recipient";
      isNormalUser = true;
    };

    warnings =
      let
        deprecationWarning =
          optname:
          "Starting in 8.0.0, the `${optname}` option has been moved from the `services.parsedmarc.settings.imap`"
          + "configuration section to the `services.parsedmarc.settings.mailbox` configuration section.";
        hasImapOpt = lib.flip builtins.hasAttr cfg.settings.imap;
        movedOptions = [
          "reports_folder"
          "archive_folder"
          "watch"
          "delete"
          "test"
          "batch_size"
        ];
      in
      map deprecationWarning (builtins.filter hasImapOpt movedOptions);
  };

  meta.doc = ./parsedmarc.md;
  meta.maintainers = [ lib.maintainers.talyz ];
}

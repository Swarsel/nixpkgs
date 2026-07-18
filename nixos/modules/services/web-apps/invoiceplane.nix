{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.invoiceplane;
  eachSite = cfg.sites;
  user = "invoiceplane";
  webserver = config.services.${cfg.webserver};

  invoiceplane-config =
    hostName: cfg:
    pkgs.writeText "ipconfig.php" ''
      # <?php exit('No direct script access allowed'); ?>

      IP_URL=http://${hostName}
      ENABLE_DEBUG=false
      DISABLE_SETUP=false
      REMOVE_INDEXPHP=false
      DB_HOSTNAME=${cfg.database.host}
      DB_USERNAME=${cfg.database.user}
      # NOTE: file_get_contents adds newline at the end of returned string
      DB_PASSWORD=${
        optionalString (
          cfg.database.passwordFile != null
        ) "trim(file_get_contents('${cfg.database.passwordFile}'), \"\\r\\n\")"
      }
      DB_DATABASE=${cfg.database.name}
      DB_PORT=${toString cfg.database.port}
      SESS_EXPIRATION=864000
      ENABLE_INVOICE_DELETION=false
      DISABLE_READ_ONLY=false
      ENCRYPTION_KEY=
      ENCRYPTION_CIPHER=AES-256
      SETUP_COMPLETED=false
      REMOVE_INDEXPHP=true
    '';

  mkPhpValue =
    v:
    if isString v then
      escapeShellArg v
    # NOTE: If any value contains a , (comma) this will not get escaped
    else if isList v && strings.isConvertibleWithToString v then
      escapeShellArg (concatMapStringsSep "," toString v)
    else if isInt v then
      toString v
    else if isBool v then
      boolToString v
    else
      abort "The Invoiceplane config value ${lib.generators.toPretty { } v} can not be encoded.";

  extraConfig =
    hostName: cfg:
    let
      settings = mapAttrsToList (k: v: "${k}=${mkPhpValue v}") cfg.settings;
    in
    pkgs.writeText "extraConfig.php" (concatStringsSep "\n" settings);

  pkg =
    hostName: cfg:
    pkgs.stdenv.mkDerivation rec {
      installPhase = ''
        mkdir -p $out
        cp -r * $out/

        # symlink uploads and log directories
        rm -r $out/uploads $out/application/logs $out/vendor/mpdf/mpdf/tmp
        ln -sf ${cfg.stateDir}/uploads $out/
        ln -sf ${cfg.stateDir}/logs $out/application/
        ln -sf ${cfg.stateDir}/tmp $out/vendor/mpdf/mpdf/

        # symlink the InvoicePlane config
        ln -s ${cfg.stateDir}/ipconfig.php $out/ipconfig.php

        # symlink the extraConfig file
        ln -s ${extraConfig hostName cfg} $out/extraConfig.php

        # symlink additional templates
        ${concatMapStringsSep "\n" (
          template: "cp -r ${template}/. $out/application/views/invoice_templates/pdf/"
        ) cfg.invoiceTemplates}
        ${concatMapStringsSep "\n" (
          template: "cp -r ${template}/. $out/application/views/quote_templates/pdf/"
        ) cfg.quoteTemplates}
      '';

      pname = "invoiceplane-${hostName}";

      postPatch = ''
        # Patch index.php file to load additional config file
        substituteInPlace index.php \
          --replace-fail "require __DIR__ . '/vendor/autoload.php';" "require('vendor/autoload.php'); \$dotenv = Dotenv\Dotenv::createImmutable(__DIR__, 'extraConfig.php'); \$dotenv->load();";
      '';

      src = pkgs.invoiceplane;
      version = src.version;
    };

  siteOpts =
    { lib, name, ... }:
    {
      options = {

        enable = mkEnableOption "InvoicePlane web application";

        cron = {
          enable = mkOption {
            default = false;

            description = ''
              Enable cron service which periodically runs Invoiceplane tasks.
              Requires key taken from the administration page. Refer to
              <https://wiki.invoiceplane.com/en/1.0/modules/recurring-invoices>
              on how to configure it.
            '';

            type = types.bool;
          };

          key = mkOption {
            description = "Cron key taken from the administration page.";
            type = types.str;
          };
        };

        database = {
          createLocally = mkOption {
            default = true;
            description = "Create the database and database user locally.";
            type = types.bool;
          };

          host = mkOption {
            default = "localhost";
            description = "Database host address.";
            type = types.str;
          };

          name = mkOption {
            default = "invoiceplane";
            description = "Database name.";
            type = types.str;
          };

          passwordFile = mkOption {
            default = null;

            description = ''
              A file containing the password corresponding to
              {option}`database.user`.
            '';

            example = "/run/keys/invoiceplane-dbpassword";
            type = types.nullOr types.path;
          };

          port = mkOption {
            default = 3306;
            description = "Database host port.";
            type = types.port;
          };

          user = mkOption {
            default = "invoiceplane";
            description = "Database user.";
            type = types.str;
          };
        };

        invoiceTemplates = mkOption {
          default = [ ];

          description = ''
            List of path(s) to respective template(s) which are copied from the 'invoice_templates/pdf' directory.

            ::: {.note}
            These templates need to be packaged before use, see example.
            :::
          '';

          example = literalExpression ''
            let
              # Let's package an example template
              template-vtdirektmarketing = pkgs.stdenv.mkDerivation {
                name = "vtdirektmarketing";
                # Download the template from a public repository
                src = pkgs.fetchgit {
                  url = "https://git.project-insanity.org/onny/invoiceplane-vtdirektmarketing.git";
                  sha256 = "1hh0q7wzsh8v8x03i82p6qrgbxr4v5fb05xylyrpp975l8axyg2z";
                };
                sourceRoot = ".";
                # Installing simply means copying template php file to the output directory
                installPhase = ""
                  mkdir -p $out
                  cp invoiceplane-vtdirektmarketing/vtdirektmarketing.php $out/
                "";
              };
            # And then pass this package to the template list like this:
            in [ template-vtdirektmarketing ]
          '';

          type = types.listOf types.path;
        };

        poolConfig = mkOption {
          default = {
            "pm" = "dynamic";
            "pm.max_children" = 32;
            "pm.max_requests" = 500;
            "pm.max_spare_servers" = 4;
            "pm.min_spare_servers" = 2;
            "pm.start_servers" = 2;
          };

          description = ''
            Options for the InvoicePlane PHP pool. See the documentation on `php-fpm.conf`
            for details on configuration directives.
          '';

          type =
            with types;
            attrsOf (oneOf [
              str
              int
              bool
            ]);
        };

        quoteTemplates = mkOption {
          default = [ ];

          description = ''
            List of path(s) to respective template(s) which are copied from the 'quote_templates/pdf' directory.

            ::: {.note}
            These templates need to be packaged before use, see example.
            :::
          '';

          example = literalExpression ''
            let
              # Let's package an example template
              template-vtdirektmarketing = pkgs.stdenv.mkDerivation {
                name = "vtdirektmarketing";
                # Download the template from a public repository
                src = pkgs.fetchgit {
                  url = "https://git.project-insanity.org/onny/invoiceplane-vtdirektmarketing.git";
                  sha256 = "1hh0q7wzsh8v8x03i82p6qrgbxr4v5fb05xylyrpp975l8axyg2z";
                };
                sourceRoot = ".";
                # Installing simply means copying template php file to the output directory
                installPhase = ""
                  mkdir -p $out
                  cp invoiceplane-vtdirektmarketing/vtdirektmarketing.php $out/
                "";
              };
            # And then pass this package to the template list like this:
            in [ template-vtdirektmarketing ]
          '';

          type = types.listOf types.path;
        };

        settings = mkOption {
          default = { };

          description = ''
            Structural InvoicePlane configuration. Refer to
            <https://github.com/InvoicePlane/InvoicePlane/blob/master/ipconfig.php.example>
            for details and supported values.
          '';

          example = literalExpression ''
            {
              SETUP_COMPLETED = true;
              DISABLE_SETUP = true;
              IP_URL = "https://invoice.example.com";
            }
          '';

          type = types.attrsOf types.anything;
        };

        stateDir = mkOption {
          default = "/var/lib/invoiceplane/${name}";

          description = ''
            This directory is used for uploads of attachments and cache.
            The directory passed here is automatically created and permissions
            adjusted as required.
          '';

          type = types.path;
        };

      };

    };
in
{
  # interface
  options = {
    services.invoiceplane = mkOption {
      default = { };
      description = "InvoicePlane configuration.";

      type = types.submodule {

        options.sites = mkOption {
          default = { };
          description = "Specification of one or more InvoicePlane sites to serve";
          type = types.attrsOf (types.submodule siteOpts);
        };

        options.webserver = mkOption {
          default = "caddy";

          description = ''
            Which webserver to use for virtual host management.
          '';

          example = "nginx";

          type = types.enum [
            "caddy"
            "nginx"
          ];
        };
      };
    };

  };

  # implementation
  config = mkIf (eachSite != { }) (mkMerge [
    {

      assertions = flatten (
        mapAttrsToList (hostName: cfg: [
          {
            assertion = cfg.database.createLocally -> cfg.database.user == user;
            message = ''services.invoiceplane.sites."${hostName}".database.user must be ${user} if the database is to be automatically provisioned'';
          }
          {
            assertion = cfg.database.createLocally -> cfg.database.passwordFile == null;
            message = ''services.invoiceplane.sites."${hostName}".database.passwordFile cannot be specified if services.invoiceplane.sites."${hostName}".database.createLocally is set to true.'';
          }
          {
            assertion = cfg.cron.enable -> cfg.cron.key != null;
            message = ''services.invoiceplane.sites."${hostName}".cron.key must be set in order to use cron service.'';
          }
        ]) eachSite
      );

      services.mysql = mkIf (any (v: v.database.createLocally) (attrValues eachSite)) {
        enable = true;
        package = mkDefault pkgs.mariadb;
        ensureDatabases = mapAttrsToList (hostName: cfg: cfg.database.name) eachSite;

        ensureUsers = mapAttrsToList (hostName: cfg: {
          ensurePermissions = {
            "${cfg.database.name}.*" = "ALL PRIVILEGES";
          };

          name = cfg.database.user;
        }) eachSite;
      };

      services.phpfpm = {
        pools = mapAttrs' (
          hostName: cfg:
          (nameValuePair "invoiceplane-${hostName}" {
            inherit user;
            group = webserver.group;

            settings = {
              "listen.group" = webserver.group;
              "listen.owner" = webserver.user;
            }
            // cfg.poolConfig;
          })
        ) eachSite;
      };

    }

    {

      systemd.services.invoiceplane-config = {
        script = concatStrings (
          mapAttrsToList (hostName: cfg: ''
            mkdir -p ${cfg.stateDir}/logs \
                     ${cfg.stateDir}/uploads
            if ! grep -q IP_URL "${cfg.stateDir}/ipconfig.php"; then
              cp "${invoiceplane-config hostName cfg}" "${cfg.stateDir}/ipconfig.php"
            fi
            if ! grep -q 'php exit' "${cfg.stateDir}/ipconfig.php"; then
              sed -i "1i # <?php exit('No direct script access allowed'); ?>" "${cfg.stateDir}/ipconfig.php"
            fi
          '') eachSite
        );

        serviceConfig.Type = "oneshot";
        wantedBy = [ "multi-user.target" ];
      };

      systemd.tmpfiles.rules = flatten (
        mapAttrsToList (hostName: cfg: [
          "d ${cfg.stateDir} 0750 ${user} ${webserver.group} - -"
          "f ${cfg.stateDir}/ipconfig.php 0750 ${user} ${webserver.group} - -"
          "d ${cfg.stateDir}/logs 0750 ${user} ${webserver.group} - -"
          "d ${cfg.stateDir}/uploads 0750 ${user} ${webserver.group} - -"
          "d ${cfg.stateDir}/uploads/archive 0750 ${user} ${webserver.group} - -"
          "d ${cfg.stateDir}/uploads/customer_files 0750 ${user} ${webserver.group} - -"
          "d ${cfg.stateDir}/uploads/temp 0750 ${user} ${webserver.group} - -"
          "d ${cfg.stateDir}/uploads/temp/mpdf 0750 ${user} ${webserver.group} - -"
          "d ${cfg.stateDir}/tmp 0750 ${user} ${webserver.group} - -"
        ]) eachSite
      );

      users.users.${user} = {
        group = webserver.group;
        isSystemUser = true;
      };

    }
    {

      systemd.services = mapAttrs' (
        hostName: cfg:
        (nameValuePair "invoiceplane-cron-${hostName}" (
          mkIf cfg.cron.enable {
            serviceConfig = {
              ExecStart = "${pkgs.curl}/bin/curl --header 'Host: ${hostName}' http://localhost/invoices/cron/recur/${cfg.cron.key}";
              Type = "oneshot";
              User = user;
            };
          }
        ))
      ) eachSite;

      # Cron service implementation
      systemd.timers = mapAttrs' (
        hostName: cfg:
        (nameValuePair "invoiceplane-cron-${hostName}" (
          mkIf cfg.cron.enable {
            timerConfig = {
              OnBootSec = "5m";
              OnUnitActiveSec = "5m";
              Unit = "invoiceplane-cron-${hostName}.service";
            };

            wantedBy = [ "timers.target" ];
          }
        ))
      ) eachSite;

    }

    (mkIf (cfg.webserver == "caddy") {
      services.caddy = {
        enable = true;

        virtualHosts = mapAttrs' (
          hostName: cfg:
          (nameValuePair hostName {
            extraConfig = ''
              root * ${pkg hostName cfg}
              file_server
              php_fastcgi unix/${config.services.phpfpm.pools."invoiceplane-${hostName}".socket}
            '';
          })
        ) eachSite;
      };
    })

    (mkIf (cfg.webserver == "nginx") {
      services.nginx = {
        enable = true;

        virtualHosts = mapAttrs' (
          hostName: cfg:
          (nameValuePair hostName {
            extraConfig = ''
              index index.php index.html index.htm;

              if (!-e $request_filename){
                rewrite ^(.*)$ /index.php break;
              }
            '';

            locations = {
              "/setup".extraConfig = ''
                rewrite ^(.*)$ http://${hostName}/ redirect;
              '';

              "~ .php$" = {
                extraConfig = ''
                  fastcgi_split_path_info ^(.+\.php)(/.+)$;
                  fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
                  fastcgi_pass unix:${config.services.phpfpm.pools."invoiceplane-${hostName}".socket};
                  include ${config.services.nginx.package}/conf/fastcgi_params;
                  include ${config.services.nginx.package}/conf/fastcgi.conf;
                '';
              };
            };

            root = pkg hostName cfg;
          })
        ) eachSite;
      };
    })

  ]);
}

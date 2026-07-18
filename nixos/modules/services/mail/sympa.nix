{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.sympa;
  dataDir = "/var/lib/sympa";
  user = "sympa";
  group = "sympa";
  pkg = pkgs.sympa;
  fqdns = lib.attrNames cfg.domains;
  usingNginx = cfg.web.enable && cfg.web.server == "nginx";
  mysqlLocal = cfg.database.createLocally && cfg.database.type == "MySQL";
  pgsqlLocal = cfg.database.createLocally && cfg.database.type == "PostgreSQL";

  sympaSubServices = [
    "sympa-archive.service"
    "sympa-bounce.service"
    "sympa-bulk.service"
    "sympa-task.service"
  ];

  # common for all services including wwsympa
  commonServiceConfig = {
    ProtectControlGroups = true;
    ProtectHome = true;
    ProtectSystem = "full";
    StateDirectory = "sympa";
  };

  # wwsympa has its own service config
  sympaServiceConfig =
    srv:
    {
      ExecStart = "${pkg}/bin/${srv}.pl --foreground";
      Group = group;
      PIDFile = "/run/sympa/${srv}.pid";
      Restart = "always";
      # avoid duplicating log messageges in journal
      StandardError = "null";
      Type = "simple";
      User = user;
    }
    // commonServiceConfig;

  configVal = value: if lib.isBool value then if value then "on" else "off" else toString value;
  configGenerator =
    c: lib.concatStrings (lib.flip lib.mapAttrsToList c (key: val: "${key}\t${configVal val}\n"));

  mainConfig = pkgs.writeText "sympa.conf" (configGenerator cfg.settings);
  robotConfig = fqdn: domain: pkgs.writeText "${fqdn}-robot.conf" (configGenerator domain.settings);

  transport = pkgs.writeText "transport.sympa" (
    lib.concatStringsSep "\n" (
      lib.flip map fqdns (domain: ''
        ${domain}                        error:User unknown in recipient table
        sympa@${domain}                  sympa:sympa@${domain}
        listmaster@${domain}             sympa:listmaster@${domain}
        bounce@${domain}                 sympabounce:sympa@${domain}
        abuse-feedback-report@${domain}  sympabounce:sympa@${domain}
      '')
    )
  );

  virtual = pkgs.writeText "virtual.sympa" (
    lib.concatStringsSep "\n" (
      lib.flip map fqdns (domain: ''
        sympa-request@${domain}  postmaster@localhost
        sympa-owner@${domain}    postmaster@localhost
      '')
    )
  );

  listAliases = pkgs.writeText "list_aliases.tt2" ''
    #--- [% list.name %]@[% list.domain %]: list transport map created at [% date %]
    [% list.name %]@[% list.domain %] sympa:[% list.name %]@[% list.domain %]
    [% list.name %]-request@[% list.domain %] sympa:[% list.name %]-request@[% list.domain %]
    [% list.name %]-editor@[% list.domain %] sympa:[% list.name %]-editor@[% list.domain %]
    #[% list.name %]-subscribe@[% list.domain %] sympa:[% list.name %]-subscribe@[%list.domain %]
    [% list.name %]-unsubscribe@[% list.domain %] sympa:[% list.name %]-unsubscribe@[% list.domain %]
    [% list.name %][% return_path_suffix %]@[% list.domain %] sympabounce:[% list.name %]@[% list.domain %]
  '';

  enabledFiles = lib.filterAttrs (n: v: v.enable) cfg.settingsFile;
in
{

  ###### interface
  options.services.sympa = with lib.types; {

    enable = lib.mkEnableOption "Sympa mailing list manager";

    database = {
      createLocally = lib.mkOption {
        default = true;
        description = "Whether to create a local database automatically.";
        type = bool;
      };

      host = lib.mkOption {
        default = null;

        description = ''
          Database host address.

          For MySQL, use `localhost` to connect using Unix domain socket.

          For PostgreSQL, use path to directory (e.g. {file}`/run/postgresql`)
          to connect using Unix domain socket located in this directory.

          Use `null` to fall back on Sympa default, or when using
          {option}`services.sympa.database.createLocally`.
        '';

        type = nullOr str;
      };

      name = lib.mkOption {
        default = if cfg.database.type == "SQLite" then "${dataDir}/sympa.sqlite" else "sympa";
        defaultText = lib.literalExpression ''if database.type == "SQLite" then "${dataDir}/sympa.sqlite" else "sympa"'';

        description = ''
          Database name. When using SQLite this must be an absolute
          path to the database file.
        '';

        type = str;
      };

      passwordFile = lib.mkOption {
        default = null;

        description = ''
          A file containing the password for {option}`services.sympa.database.name`.
        '';

        example = "/run/keys/sympa-dbpassword";
        type = nullOr path;
      };

      port = lib.mkOption {
        default = null;
        description = "Database port. Use `null` for default port.";
        type = nullOr port;
      };

      type = lib.mkOption {
        default = "SQLite";
        description = "Database engine to use.";
        example = "MySQL";

        type = enum [
          "SQLite"
          "PostgreSQL"
          "MySQL"
        ];
      };

      user = lib.mkOption {
        default = user;
        description = "Database user. The system user name is used as a default.";
        type = nullOr str;
      };
    };

    domains = lib.mkOption {
      description = ''
        Email domains handled by this instance. There have
        to be MX records for keys of this attribute set.
      '';

      example = lib.literalExpression ''
        {
          "lists.example.org" = {
            webHost = "lists.example.org";
            webLocation = "/";
          };
          "sympa.example.com" = {
            webHost = "example.com";
            webLocation = "/sympa";
          };
        }
      '';

      type = attrsOf (
        submodule (
          { config, name, ... }:
          {
            options = {
              settings = lib.mkOption {
                default = { };

                description = ''
                  The {file}`robot.conf` configuration file as key value set.
                  See <https://sympa-community.github.io/gpldoc/man/sympa.conf.5.html>
                  for list of configuration parameters.
                '';

                example = {
                  default_max_list_members = 3;
                };

                type = attrsOf (oneOf [
                  str
                  int
                  bool
                ]);
              };

              webHost = lib.mkOption {
                default = null;

                description = ''
                  Domain part of the web interface URL (no web interface for this domain if `null`).
                  DNS record of type A (or AAAA or CNAME) has to exist with this value.
                '';

                example = "archive.example.org";
                type = nullOr str;
              };

              webLocation = lib.mkOption {
                default = "/";
                description = "URL path part of the web interface.";
                example = "/sympa";
                type = str;
              };
            };

            config.settings = lib.mkIf (cfg.web.enable && config.webHost != null) {
              wwsympa_url = lib.mkDefault "https://${config.webHost}${lib.removeSuffix "/" config.webLocation}";
            };
          }
        )
      );
    };

    lang = lib.mkOption {
      default = "en_US";

      description = ''
        Default Sympa language.
        See <https://github.com/sympa-community/sympa/tree/sympa-6.2/po/sympa>
        for available options.
      '';

      example = "cs";
      type = str;
    };

    listMasters = lib.mkOption {
      description = ''
        The list of the email addresses of the listmasters
        (users authorized to perform global server commands).
      '';

      example = [ "postmaster@sympa.example.org" ];
      type = listOf str;
    };

    mainDomain = lib.mkOption {
      default = null;

      description = ''
        Main domain to be used in {file}`sympa.conf`.
        If `null`, one of the {option}`services.sympa.domains` is chosen for you.
      '';

      example = "lists.example.org";
      type = nullOr str;
    };

    mta = {
      type = lib.mkOption {
        default = "postfix";

        description = ''
          Mail transfer agent (MTA) integration. Use `none` if you want to configure it yourself.

          The `postfix` integration sets up local Postfix instance that will pass incoming
          messages from configured domains to Sympa. You still need to configure at least outgoing message
          handling using e.g. {option}`services.postfix.relayHost`.
        '';

        type = enum [
          "postfix"
          "none"
        ];
      };
    };

    settings = lib.mkOption {
      default = { };

      description = ''
        The {file}`sympa.conf` configuration file as key value set.
        See <https://sympa-community.github.io/gpldoc/man/sympa.conf.5.html>
        for list of configuration parameters.
      '';

      example = lib.literalExpression ''
        {
          default_home = "lists";
          viewlogs_page_size = 50;
        }
      '';

      type = attrsOf (oneOf [
        str
        int
        bool
      ]);
    };

    settingsFile = lib.mkOption {
      default = { };
      description = "Set of files to be linked in {file}`${dataDir}`.";

      example = lib.literalExpression ''
        {
          "list_data/lists.example.org/help" = {
            text = "subject This list provides help to users";
          };
        }
      '';

      type = attrsOf (
        submodule (
          { config, name, ... }:
          {
            options = {
              enable = lib.mkOption {
                default = true;
                description = "Whether this file should be generated. This option allows specific files to be disabled.";
                type = bool;
              };

              source = lib.mkOption {
                description = "Path of the source file.";
                type = path;
              };

              text = lib.mkOption {
                default = null;
                description = "Text of the file.";
                type = nullOr lines;
              };
            };

            config.source = lib.mkIf (config.text != null) (
              lib.mkDefault (pkgs.writeText "sympa-${baseNameOf name}" config.text)
            );
          }
        )
      );
    };

    web = {
      enable = lib.mkOption {
        default = true;
        description = "Whether to enable Sympa web interface.";
        type = bool;
      };

      fcgiProcs = lib.mkOption {
        default = 2;
        description = "Number of FastCGI processes to fork.";
        type = ints.positive;
      };

      https = lib.mkOption {
        default = true;

        description = ''
          Whether to use HTTPS. When nginx integration is enabled, this option forces SSL and enables ACME.
          Please note that Sympa web interface always uses https links even when this option is disabled.
        '';

        type = bool;
      };

      server = lib.mkOption {
        default = "nginx";

        description = ''
          The webserver used for the Sympa web interface. Set it to `none` if you want to configure it yourself.
          Further nginx configuration can be done by adapting
          {option}`services.nginx.virtualHosts.«name»`.
        '';

        type = enum [
          "nginx"
          "none"
        ];
      };
    };
  };

  ###### implementation

  config = lib.mkIf cfg.enable {

    assertions = [
      {
        assertion =
          cfg.database.createLocally -> cfg.database.user == user && cfg.database.name == cfg.database.user;

        message = "services.sympa.database.user must be set to ${user} if services.sympa.database.createLocally is set to true";
      }
      {
        assertion = cfg.database.createLocally -> cfg.database.passwordFile == null;
        message = "a password cannot be specified if services.sympa.database.createLocally is set to true";
      }
    ];

    environment = {
      systemPackages = [ pkg ];
    };

    services.mysql = lib.optionalAttrs mysqlLocal {
      enable = true;
      package = lib.mkDefault pkgs.mariadb;
      ensureDatabases = [ cfg.database.name ];

      ensureUsers = [
        {
          ensurePermissions = {
            "${cfg.database.name}.*" = "ALL PRIVILEGES";
          };

          name = cfg.database.user;
        }
      ];
    };

    services.nginx.enable = lib.mkIf usingNginx true;

    services.nginx.virtualHosts = lib.mkIf usingNginx (
      let
        vHosts = lib.unique (lib.remove null (lib.mapAttrsToList (_k: v: v.webHost) cfg.domains));
        hostLocations =
          host: map (v: v.webLocation) (lib.filter (v: v.webHost == host) (lib.attrValues cfg.domains));
        httpsOpts = lib.optionalAttrs cfg.web.https {
          enableACME = lib.mkDefault true;
          forceSSL = lib.mkDefault true;
        };
      in
      lib.genAttrs vHosts (
        host:
        {
          locations =
            lib.genAttrs (hostLocations host) (loc: {
              extraConfig = ''
                include ${config.services.nginx.package}/conf/fastcgi_params;

                fastcgi_pass unix:/run/sympa/wwsympa.socket;
              '';
            })
            // {
              "/static-sympa/".alias = "${dataDir}/static_content/";
            };
        }
        // httpsOpts
      )
    );

    services.postfix = lib.mkIf (cfg.mta.type == "postfix") {
      enable = true;

      settings = {
        main = {
          recipient_delimiter = "+";

          transport_maps = [
            "hash:${dataDir}/transport.sympa"
            "hash:${dataDir}/sympa_transport"
          ];

          virtual_alias_maps = [ "hash:${dataDir}/virtual.sympa" ];
          virtual_mailbox_domains = [ "hash:${dataDir}/transport.sympa" ];

          virtual_mailbox_maps = [
            "hash:${dataDir}/transport.sympa"
            "hash:${dataDir}/sympa_transport"
            "hash:${dataDir}/virtual.sympa"
          ];
        };

        master = {
          "sympa" = {
            args = [
              "flags=hqRu"
              "user=${user}"
              "argv=${pkg}/libexec/queue"
              "\${nexthop}"
            ];

            chroot = false;
            command = "pipe";
            privileged = true;
            type = "unix";
          };

          "sympabounce" = {
            args = [
              "flags=hqRu"
              "user=${user}"
              "argv=${pkg}/libexec/bouncequeue"
              "\${nexthop}"
            ];

            chroot = false;
            command = "pipe";
            privileged = true;
            type = "unix";
          };
        };
      };
    };

    services.postgresql = lib.optionalAttrs pgsqlLocal {
      enable = true;
      ensureDatabases = [ cfg.database.name ];

      ensureUsers = [
        {
          ensureDBOwnership = true;
          name = cfg.database.user;
        }
      ];
    };

    services.sympa.settings = (
      lib.mapAttrs (_: v: lib.mkDefault v) {
        arc_path = "${dataDir}/arc";
        bounce_path = "${dataDir}/bounce";
        db_name = cfg.database.name;
        db_type = cfg.database.type;
        db_user = cfg.database.name;
        domain = if cfg.mainDomain != null then cfg.mainDomain else lib.head fqdns;
        home = "${dataDir}/list_data";
        lang = cfg.lang;
        listmaster = lib.concatStringsSep "," cfg.listMasters;
        sendmail = "${pkgs.system-sendmail}/bin/sendmail";
      }
      // (lib.optionalAttrs (cfg.database.host != null) {
        db_host = cfg.database.host;
      })
      // (lib.optionalAttrs mysqlLocal {
        db_host = "localhost"; # use unix domain socket
      })
      // (lib.optionalAttrs pgsqlLocal {
        db_host = "/run/postgresql"; # use unix domain socket
      })
      // (lib.optionalAttrs (cfg.database.port != null) {
        db_port = cfg.database.port;
      })
      // (lib.optionalAttrs (cfg.mta.type == "postfix") {
        aliases_db_type = "hash";
        aliases_program = lib.getExe' config.services.postfix.package "postmap";
        sendmail_aliases = "${dataDir}/sympa_transport";
      })
      // (lib.optionalAttrs cfg.web.enable {
        css_path = "${dataDir}/static_content/css";
        mhonarc = "${pkgs.perlPackages.MHonArc}/bin/mhonarc";
        pictures_path = "${dataDir}/static_content/pictures";
        static_content_path = "${dataDir}/static_content";
      })
    );

    services.sympa.settingsFile = {
      "etc/list_aliases.tt2" = lib.mkDefault { source = listAliases; };
      "transport.sympa" = lib.mkDefault { source = transport; };
      "virtual.sympa" = lib.mkDefault { source = virtual; };
    }
    // (lib.flip lib.mapAttrs' cfg.domains (
      fqdn: domain:
      lib.nameValuePair "etc/${fqdn}/robot.conf" (lib.mkDefault { source = robotConfig fqdn domain; })
    ));

    systemd.services.sympa = {
      after = [ "network-online.target" ];
      before = sympaSubServices;
      description = "Sympa mailing list manager";

      preStart = ''
        umask 0077

        cp -f ${mainConfig} ${dataDir}/etc/sympa.conf
        ${lib.optionalString (cfg.database.passwordFile != null) ''
          chmod u+w ${dataDir}/etc/sympa.conf
          echo -n "db_passwd " >> ${dataDir}/etc/sympa.conf
          cat ${cfg.database.passwordFile} >> ${dataDir}/etc/sympa.conf
        ''}

        ${lib.optionalString (cfg.mta.type == "postfix") ''
          ${lib.getExe' config.services.postfix.package "postmap"} hash:${dataDir}/virtual.sympa
          ${lib.getExe' config.services.postfix.package "postmap"} hash:${dataDir}/transport.sympa
        ''}
        ${pkg}/bin/sympa_newaliases.pl
        ${pkg}/bin/sympa.pl --health_check
      '';

      serviceConfig = sympaServiceConfig "sympa_msg";
      wantedBy = [ "multi-user.target" ];
      wants = sympaSubServices ++ [ "network-online.target" ];
    };

    systemd.services.sympa-archive = {
      bindsTo = [ "sympa.service" ];
      description = "Sympa mailing list manager (archiving)";
      serviceConfig = sympaServiceConfig "archived";
    };

    systemd.services.sympa-bounce = {
      bindsTo = [ "sympa.service" ];
      description = "Sympa mailing list manager (bounce processing)";
      serviceConfig = sympaServiceConfig "bounced";
    };

    systemd.services.sympa-bulk = {
      bindsTo = [ "sympa.service" ];
      description = "Sympa mailing list manager (message distribution)";
      serviceConfig = sympaServiceConfig "bulk";
    };

    systemd.services.sympa-task = {
      bindsTo = [ "sympa.service" ];
      description = "Sympa mailing list manager (task management)";
      serviceConfig = sympaServiceConfig "task_manager";
    };

    systemd.services.wwsympa = lib.mkIf usingNginx {
      after = [ "sympa.service" ];

      serviceConfig = {
        ExecStart = ''
          ${pkgs.spawn_fcgi}/bin/spawn-fcgi \
                    -u ${user} \
                    -g ${group} \
                    -U nginx \
                    -M 0600 \
                    -F ${toString cfg.web.fcgiProcs} \
                    -P /run/sympa/wwsympa.pid \
                    -s /run/sympa/wwsympa.socket \
                    -- ${pkg}/lib/sympa/cgi/wwsympa.fcgi
        '';

        PIDFile = "/run/sympa/wwsympa.pid";
        Restart = "always";
        Type = "forking";

      }
      // commonServiceConfig;

      wantedBy = [ "multi-user.target" ];
    };

    systemd.tmpfiles.rules = [
      "d  ${dataDir}                   0711 ${user} ${group} - -"
      "d  ${dataDir}/etc               0700 ${user} ${group} - -"
      "d  ${dataDir}/spool             0700 ${user} ${group} - -"
      "d  ${dataDir}/list_data         0700 ${user} ${group} - -"
      "d  ${dataDir}/arc               0700 ${user} ${group} - -"
      "d  ${dataDir}/bounce            0700 ${user} ${group} - -"
      "f  ${dataDir}/sympa_transport   0600 ${user} ${group} - -"

      # force-copy static_content so it's up to date with package
      # set permissions for wwsympa which needs write access (...)
      "R  ${dataDir}/static_content    -    -       -        - -"
      "C  ${dataDir}/static_content    0711 ${user} ${group} - ${pkg}/var/lib/sympa/static_content"
      "e  ${dataDir}/static_content/*  0711 ${user} ${group} - -"

      "d  /run/sympa                   0755 ${user} ${group} - -"
    ]
    ++ (lib.flip lib.concatMap fqdns (fqdn: [
      "d  ${dataDir}/etc/${fqdn}       0700 ${user} ${group} - -"
      "d  ${dataDir}/list_data/${fqdn} 0700 ${user} ${group} - -"
    ]))
    #++ (lib.flip lib.mapAttrsToList enabledFiles (k: v:
    #  "L+ ${dataDir}/${k}              -    -       -        - ${v.source}"
    #))
    ++ (lib.concatLists (
      lib.flip lib.mapAttrsToList enabledFiles (
        k: v: [
          # sympa doesn't handle symlinks well (e.g. fails to create locks)
          # force-copy instead
          "R ${dataDir}/${k}              -    -       -        - -"
          "C ${dataDir}/${k}              0700 ${user}  ${group} - ${v.source}"
        ]
      )
    ));

    users.groups.${group} = { };

    users.users.${user} = {
      createHome = false;
      description = "Sympa mailing list manager user";
      group = group;
      home = dataDir;
      isSystemUser = true;
    };

  };

  meta.maintainers = with lib.maintainers; [
    sorki
  ];
}

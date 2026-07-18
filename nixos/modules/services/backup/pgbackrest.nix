{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.pgbackrest;

  settingsFormat = pkgs.formats.ini {
    listsAsDuplicateKeys = true;
  };

  # pgBackRest "options"
  settingsType =
    with lib.types;
    attrsOf (oneOf [
      bool
      ints.unsigned
      str
      (attrsOf str)
      (listOf str)
    ]);

  # Applied to both repoNNN-* and pgNNN-* options in global and stanza sections.
  flattenWithIndex =
    attrs: prefix:
    lib.concatMapAttrs (
      name:
      let
        index = lib.lists.findFirstIndex (n: n == name) null (lib.attrNames attrs);
        index1 = index + 1;
      in
      lib.mapAttrs' (option: lib.nameValuePair "${prefix}${toString index1}-${option}")
    ) attrs;

  # Remove nulls, turn attrsets into lists and bools into y/n
  normalize =
    x:
    lib.pipe x [
      (lib.filterAttrs (_: v: v != null))
      (lib.mapAttrs (_: v: if lib.isAttrs v then lib.mapAttrsToList (n': v': "${n'}=${v'}") v else v))
      (lib.mapAttrs (
        _: v:
        if v == true then
          "y"
        else if v == false then
          "n"
        else
          v
      ))
    ];

  fullConfig = {
    global = normalize (cfg.settings // flattenWithIndex cfg.repos "repo");
  }
  // lib.mapAttrs' (
    cmd: settings: lib.nameValuePair "global:${cmd}" (normalize settings)
  ) cfg.commands
  // lib.mapAttrs (
    _: cfg': normalize (cfg'.settings // flattenWithIndex cfg'.instances "pg")
  ) cfg.stanzas;

  namedJobs = lib.listToAttrs (
    lib.flatten (
      lib.mapAttrsToList (
        stanza:
        { jobs, ... }:
        lib.mapAttrsToList (
          job: attrs: lib.nameValuePair "pgbackrest-${stanza}-${job}" (attrs // { inherit stanza job; })
        ) jobs
      ) cfg.stanzas
    )
  );

  disabledOption = lib.mkOption {
    default = null;
    internal = true;
    readOnly = true;
  };

  secretPathOption =
    with lib.types;
    lib.mkOption {
      default = null;
      internal = true;
      type = nullOr externalPath;
    };
in

{
  # TODO: Add enableServer option and corresponding pgBackRest TLS server service.
  # TODO: Write wrapper around pgbackrest to turn --repo=<name> into --repo=<number>
  # The following two are dependent on improvements upstream:
  #   https://github.com/pgbackrest/pgbackrest/issues/2621
  # TODO: Add support for more repository types
  # TODO: Support passing encryption key safely
  options.services.pgbackrest = {
    enable = lib.mkEnableOption "pgBackRest";

    commands =
      lib.genAttrs
        [
          # List of commands from https://pgbackrest.org/command.html:
          "annotate"
          "archive-get"
          "archive-push"
          "backup"
          "check"
          "expire"
          "help"
          "info"
          "repo-get"
          "repo-ls"
          "restore"
          "server"
          "server-ping"
          "stanza-create"
          "stanza-delete"
          "stanza-upgrade"
          "start"
          "stop"
          "verify"
          "version"
        ]
        (
          command:
          lib.mkOption {
            default = { };

            description = ''
              Options for the '${command}' command.

              An attribute set of options as described in:
              <https://pgbackrest.org/configuration.html>

              All globally available options, i.e. all except stanza options, can be used.
              Repository options should be set via [`repos`](#opt-services.pgbackrest.repos) instead.
            '';

            type = lib.types.submodule {
              # The following options are not fully supported / tested, yet, but point to files with secrets.
              # Users can already set those options, but we'll force non-store paths.
              options.tls-server-cert-file = secretPathOption;
              options.tls-server-key-file = secretPathOption;
              freeformType = settingsType;
            };
          }
        );

    repos = lib.mkOption {
      default = { };

      description = ''
        An attribute set of repositories as described in:
        <https://pgbackrest.org/configuration.html#section-repository>

        Each repository defaults to set `repo-host` to the attribute's name.
        The special value "localhost" will unset `repo-host`.

        ::: {.note}
        The prefix `repoNNN-` is added automatically.
        Example: Use `path` instead of `repo1-path`.
        :::
      '';

      example = lib.literalExpression ''
        {
          localhost.path = "/var/lib/backup";
          "backup.example.com".host-type = "tls";
        }
      '';

      type =
        with lib.types;
        attrsOf (
          submodule (
            { config, name, ... }:
            let
              setHostForType =
                type:
                if name == "localhost" then
                  null
                # "posix" is the default repo type, which uses the -host option.
                # Other types use prefixed options, for example -sftp-host.
                else if config.type or "posix" != type then
                  null
                else
                  name;
            in
            {
              # The following options should not be used; they would store secrets in the store.
              options.azure-key = disabledOption;
              options.cipher-pass = disabledOption;
              # The following options are not fully supported / tested, yet, but point to files with secrets.
              # Users can already set those options, but we'll force non-store paths.
              options.gcs-key = secretPathOption;

              options.host = lib.mkOption {
                default = setHostForType "posix";
                defaultText = lib.literalExpression "name";
                description = "Repository host when operating remotely";
                type = nullOr str;
              };

              options.host-cert-file = secretPathOption;
              options.host-key-file = secretPathOption;
              options.s3-key = disabledOption;
              options.s3-key-secret = disabledOption;
              options.s3-kms-key-id = disabledOption; # unsure whether that's a secret or not
              options.s3-sse-customer-key = disabledOption; # unsure whether that's a secret or not
              options.s3-token = disabledOption;

              options.sftp-host = lib.mkOption {
                default = setHostForType "sftp";
                defaultText = lib.literalExpression "name";
                description = "SFTP repository host";
                type = nullOr str;
              };

              options.sftp-private-key-file = lib.mkOption {
                default = null;

                description = ''
                  SFTP private key file.

                  The file must be accessible by both the pgbackrest and the postgres users.
                '';

                type = nullOr externalPath;
              };

              options.sftp-private-key-passphrase = disabledOption;
              freeformType = settingsType;
            }
          )
        );
    };

    settings = lib.mkOption {
      default = { };

      description = ''
        An attribute set of options as described in:
        <https://pgbackrest.org/configuration.html>

        All globally available options, i.e. all except stanza options, can be used.
        Repository options should be set via [`repos`](#opt-services.pgbackrest.repos) instead.
      '';

      example = lib.literalExpression ''
        {
          process-max = 2;
        }
      '';

      type = lib.types.submodule {
        # The following options are not fully supported / tested, yet, but point to files with secrets.
        # Users can already set those options, but we'll force non-store paths.
        options.tls-server-cert-file = secretPathOption;
        options.tls-server-key-file = secretPathOption;
        freeformType = settingsType;
      };
    };

    stanzas = lib.mkOption {
      default = { };

      description = ''
        An attribute set of stanzas as described in:
        <https://pgbackrest.org/user-guide.html#quickstart/configure-stanza>
      '';

      type =
        with lib.types;
        attrsOf (submodule {
          options = {
            instances = lib.mkOption {
              default = { };

              description = ''
                An attribute set of database instances as described in:
                <https://pgbackrest.org/configuration.html#section-stanza>

                Each instance defaults to set `pg-host` to the attribute's name.
                The special value "localhost" will unset `pg-host`.

                ::: {.note}
                The prefix `pgNNN-` is added automatically.
                Example: Use `user` instead of `pg1-user`.
                :::
              '';

              example = lib.literalExpression ''
                {
                  localhost.database = "app";
                  "postgres.example.com".port = "5433";
                }
              '';

              type =
                with lib.types;
                attrsOf (
                  submodule (
                    { name, ... }:
                    {
                      options.host = lib.mkOption {
                        default = if name == "localhost" then null else name;
                        defaultText = lib.literalExpression ''if name == "localhost" then null else name'';
                        description = "PostgreSQL host for operating remotely.";
                        type = nullOr str;
                      };

                      # The following options are not fully supported / tested, yet, but point to files with secrets.
                      # Users can already set those options, but we'll force non-store paths.
                      options.host-cert-file = secretPathOption;
                      options.host-key-file = secretPathOption;
                      freeformType = settingsType;
                    }
                  )
                );
            };

            jobs = lib.mkOption {
              default = { };

              description = ''
                Backups jobs to schedule for this stanza as described in:
                <https://pgbackrest.org/user-guide.html#quickstart/schedule-backup>
              '';

              example = lib.literalExpression ''
                {
                  weekly = { schedule = "Sun, 6:30"; type = "full"; };
                  daily = { schedule = "Mon..Sat, 6:30"; type = "diff"; };
                }
              '';

              type = lib.types.attrsOf (
                lib.types.submodule {
                  options.schedule = lib.mkOption {
                    description = ''
                      When or how often the backup should run.
                      Must be in the format described in {manpage}`systemd.time(7)`.
                    '';

                    type = lib.types.str;
                  };

                  options.type = lib.mkOption {
                    description = ''
                      Backup type as described in:
                      <https://pgbackrest.org/command.html#command-backup/category-command/option-type>
                    '';

                    type = lib.types.str;
                  };
                }
              );
            };

            settings = lib.mkOption {
              default = { };

              description = ''
                An attribute set of options as described in:
                <https://pgbackrest.org/configuration.html>

                All options can be used.
                Repository options should be set via [`repos`](#opt-services.pgbackrest.repos) instead.
                Stanza options should be set via [`instances`](#opt-services.pgbackrest.stanzas._name_.instances) instead.
              '';

              example = lib.literalExpression ''
                {
                  process-max = 2;
                }
              '';

              type = lib.types.submodule {
                # The following options are not fully supported / tested, yet, but point to files with secrets.
                # Users can already set those options, but we'll force non-store paths.
                options.tls-server-cert-file = secretPathOption;
                options.tls-server-key-file = secretPathOption;
                freeformType = settingsType;
              };
            };
          };
        });
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        environment.etc."pgbackrest/pgbackrest.conf".source =
          settingsFormat.generate "pgbackrest.conf" fullConfig;

        environment.systemPackages = [ pkgs.pgbackrest ];

        services.pgbackrest.settings = {
          cmd-ssh = lib.getExe pkgs.openssh;
          log-level-console = lib.mkDefault "info";
          log-level-file = lib.mkDefault "off";
        };

        systemd.services = lib.mapAttrs (
          _:
          {
            job,
            stanza,
            type,
            ...
          }:
          {
            description = "pgBackRest job ${job} for stanza ${stanza}";

            serviceConfig = {
              ExecStart = "${lib.getExe pkgs.pgbackrest} --stanza='${stanza}' backup --type='${type}'";
              # stanza-create is idempotent, so safe to always run
              ExecStartPre = "${lib.getExe pkgs.pgbackrest} --stanza='${stanza}' stanza-create";
              Group = "pgbackrest";
              Type = "oneshot";
              User = "pgbackrest";
            };
          }
        ) namedJobs;

        systemd.timers = lib.mapAttrs (
          name:
          {
            job,
            schedule,
            stanza,
            ...
          }:
          {
            after = [ "network-online.target" ];
            description = "pgBackRest job ${job} for stanza ${stanza}";

            timerConfig = {
              OnCalendar = schedule;
              Persistent = true;
              Unit = "${name}.service";
            };

            wantedBy = [ "timers.target" ];
            wants = [ "network-online.target" ];
          }
        ) namedJobs;

        users.groups.pgbackrest = { };

        users.users.pgbackrest = {
          createHome = true;
          description = "pgBackRest service user";
          group = "pgbackrest";
          home = cfg.repos.localhost.path or "/var/lib/pgbackrest";
          isSystemUser = true;
          name = "pgbackrest";
          useDefaultShell = true;
        };
      }

      # The default stanza is set up for the local postgresql instance.
      # It does not backup automatically, the systemd timer still needs to be set.
      (lib.mkIf config.services.postgresql.enable {
        # If PostgreSQL runs on the same machine, any restore will have to be done with that user.
        # Keeping the lock file in a directory writeable by the postgres user prevents errors.
        services.pgbackrest.commands.restore.lock-path = "/tmp/postgresql";

        services.pgbackrest.stanzas.default = {
          instances.localhost = {
            path = config.services.postgresql.dataDir;
            user = "postgres";
          };

          settings.cmd = lib.getExe pkgs.pgbackrest;
        };

        services.postgresql.identMap = ''
          postgres pgbackrest postgres
        '';

        services.postgresql.initdbArgs = [ "--allow-group-access" ];

        services.postgresql.settings = {
          archive_command = ''${lib.getExe pkgs.pgbackrest} --stanza=default archive-push "%p"'';
          archive_mode = lib.mkDefault "on";
        };

        users.groups.pgbackrest.members = [ "postgres" ];
        users.users.pgbackrest.extraGroups = [ "postgres" ];
      })
    ]
  );

  meta = {
    maintainers = with lib.maintainers; [ wolfgangwalther ];
  };
}

{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.services.bitwarden-directory-connector-cli;
in
{
  options.services.bitwarden-directory-connector-cli = {
    enable = mkEnableOption "Bitwarden Directory Connector";
    package = mkPackageOption pkgs "bitwarden-directory-connector-cli" { };

    domain = mkOption {
      description = "The domain the Bitwarden/Vaultwarden is accessible on.";
      example = "https://vaultwarden.example.com";
      type = types.str;
    };

    interval = mkOption {
      default = "*:0,15,30,45";
      description = "The interval when to run the connector. This uses systemd's OnCalendar syntax.";
      type = types.str;
    };

    ldap = mkOption {
      default = { };

      description = ''
        Options to configure the LDAP connection.
        If you used the desktop application to test the configuration you can find the settings by searching for `ldap` in `~/.config/Bitwarden\ Directory\ Connector/data.json`.
      '';

      type = types.submodule (
        {
          config,
          options,
          ...
        }:
        {
          options = {
            ad = mkOption {
              default = false;
              description = "Whether the LDAP Server is an Active Directory.";
              type = types.bool;
            };

            finalJSON = mkOption {
              internal = true;
              readOnly = true;
              type = (pkgs.formats.json { }).type;
              visible = false;
            };

            hostname = mkOption {
              description = "The host the LDAP is accessible on.";
              example = "ldap.example.com";
              type = types.str;
            };

            pagedSearch = mkOption {
              default = false;
              description = "Whether the LDAP server paginates search results.";
              type = types.bool;
            };

            port = mkOption {
              default = 389;
              description = "Port LDAP is accessible on.";
              type = types.port;
            };

            rootPath = mkOption {
              description = "Root path for LDAP.";
              example = "dc=example,dc=com";
              type = types.str;
            };

            ssl = mkOption {
              default = false;
              description = "Whether to use TLS.";
              type = types.bool;
            };

            startTls = mkOption {
              default = false;
              description = "Whether to use STARTTLS.";
              type = types.bool;
            };

            username = mkOption {
              description = "The user to authenticate as.";
              example = "cn=admin,dc=example,dc=com";
              type = types.str;
            };
          };

          config.finalJSON = builtins.toJSON (
            removeAttrs config (
              filter (x: x == "finalJSON" || !options.${x}.isDefined or false) (attrNames options)
            )
          );

          freeformType = types.attrsOf (pkgs.formats.json { }).type;
        }
      );
    };

    secrets = {
      bitwarden = {
        client_path_id = mkOption {
          description = "Path to file that contains Client ID.";
          type = types.str;
        };

        client_path_secret = mkOption {
          description = "Path to file that contains Client Secret.";
          type = types.str;
        };
      };

      ldap = mkOption {
        description = "Path to file that contains LDAP password for user in {option}`ldap.username";
        type = types.str;
      };
    };

    sync = mkOption {
      default = { };

      description = ''
        Options to configure what gets synced.
        If you used the desktop application to test the configuration you can find the settings by searching for `sync` in `~/.config/Bitwarden\ Directory\ Connector/data.json`.
      '';

      type = types.submodule (
        {
          config,
          options,
          ...
        }:
        {
          options = {
            creationDateAttribute = mkOption {
              description = "Attribute that lists a user's creation date.";
              example = "whenCreated";
              type = types.str;
            };

            emailPrefixAttribute = mkOption {
              description = "The attribute that contains the users username.";
              example = "accountName";
              type = types.str;
            };

            emailSuffix = mkOption {
              description = "Suffix for the email, normally @example.com.";
              example = "@example.com";
              type = types.str;
            };

            finalJSON = mkOption {
              internal = true;
              readOnly = true;
              type = (pkgs.formats.json { }).type;
              visible = false;
            };

            groupFilter = mkOption {
              default = "";
              description = "LDAP filter for groups.";
              example = "(cn=sales)";
              type = types.str;
            };

            groupNameAttribute = mkOption {
              default = "cn";
              description = "Attribute for a name of group.";
              type = types.str;
            };

            groupObjectClass = mkOption {
              default = "groupOfNames";
              description = "A class that groups will have.";
              type = types.str;
            };

            groupPath = mkOption {
              default = "ou=groups";
              description = "Group directory, relative to root.";
              type = types.str;
            };

            groups = mkOption {
              default = false;
              description = "Whether to sync ldap groups into BitWarden.";
              type = types.bool;
            };

            largeImport = mkOption {
              default = false;
              description = "Enable if you are syncing more than 2000 users/groups.";
              type = types.bool;
            };

            memberAttribute = mkOption {
              description = "Attribute that lists members in a LDAP group.";
              example = "uniqueMember";
              type = types.str;
            };

            overwriteExisting = mkOption {
              default = false;
              description = "Remove and re-add users/groups, See <https://bitwarden.com/help/user-group-filters/#overwriting-syncs> for more details.";
              type = types.bool;
            };

            removeDisabled = mkOption {
              default = true;
              description = "Remove users from bitwarden groups if no longer in the ldap group.";
              type = types.bool;
            };

            useEmailPrefixSuffix = mkOption {
              default = false;
              description = "If a user has no email address, combine a username prefix with a suffix value to form an email.";
              type = types.bool;
            };

            userEmailAttribute = mkOption {
              default = "mail";
              description = "Attribute for a users email.";
              type = types.str;
            };

            userFilter = mkOption {
              default = "";
              description = "LDAP filter for users.";
              example = "(memberOf=cn=sales,ou=groups,dc=example,dc=com)";
              type = types.str;
            };

            userObjectClass = mkOption {
              default = "inetOrgPerson";
              description = "Class that users must have.";
              type = types.str;
            };

            userPath = mkOption {
              default = "ou=users";
              description = "User directory, relative to root.";
              type = types.str;
            };

            users = mkOption {
              default = false;
              description = "Sync users.";
              type = types.bool;
            };
          };

          config.finalJSON = builtins.toJSON (
            removeAttrs config (
              filter (x: x == "finalJSON" || !options.${x}.isDefined or false) (attrNames options)
            )
          );

          freeformType = types.attrsOf (pkgs.formats.json { }).type;
        }
      );
    };

    user = mkOption {
      default = "bwdc";
      description = "User to run the program.";
      type = types.str;
    };
  };

  config = mkIf cfg.enable {
    systemd = {
      services.bitwarden-directory-connector-cli = {
        description = "Main process for Bitwarden Directory Connector";

        environment = {
          BITWARDENCLI_CONNECTOR_APPDATA_DIR = "/tmp";
          BITWARDENCLI_CONNECTOR_PLAINTEXT_SECRETS = "true";
        };

        path = [ pkgs.jq ];

        preStart = ''
          set -eo pipefail

          # create the config file
          ${lib.getExe cfg.package} data-file
          touch /tmp/data.json.tmp
          chmod 600 /tmp/data.json{,.tmp}

          ${lib.getExe cfg.package} config server ${cfg.domain}

          # now login to set credentials
          export BW_CLIENTID="$(< ${escapeShellArg cfg.secrets.bitwarden.client_path_id})"
          export BW_CLIENTSECRET="$(< ${escapeShellArg cfg.secrets.bitwarden.client_path_secret})"
          ${lib.getExe cfg.package} login

          jq '.authenticatedAccounts[0] as $account
            | .[$account].directoryConfigurations.ldap |= $ldap_data
            | .[$account].directorySettings.organizationId |= $orgID
            | .[$account].directorySettings.sync |= $sync_data' \
            --argjson ldap_data ${escapeShellArg cfg.ldap.finalJSON} \
            --arg orgID "''${BW_CLIENTID//organization.}" \
            --argjson sync_data ${escapeShellArg cfg.sync.finalJSON} \
            /tmp/data.json \
            > /tmp/data.json.tmp

          mv -f /tmp/data.json.tmp /tmp/data.json

          # final config
          ${lib.getExe cfg.package} config directory 0
          ${lib.getExe cfg.package} config ldap.password --secretfile ${cfg.secrets.ldap}
        '';

        serviceConfig = {
          ExecStart = "${lib.getExe cfg.package} sync";
          PrivateTmp = true;
          Type = "oneshot";
          User = "${cfg.user}";
        };
      };

      timers.bitwarden-directory-connector-cli = {
        after = [ "network-online.target" ];
        description = "Sync timer for Bitwarden Directory Connector";

        timerConfig = {
          OnCalendar = cfg.interval;
          Persistent = true;
          Unit = "bitwarden-directory-connector-cli.service";
        };

        wantedBy = [ "timers.target" ];
        wants = [ "network-online.target" ];
      };
    };

    users.groups."${cfg.user}" = { };

    users.users."${cfg.user}" = {
      group = cfg.user;
      isSystemUser = true;
    };
  };

  meta.maintainers = with maintainers; [ Silver-Golden ];
}

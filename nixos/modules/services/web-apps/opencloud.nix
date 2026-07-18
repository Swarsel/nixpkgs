{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) types;
  cfg = config.services.opencloud;

  defaultUser = "opencloud";
  defaultGroup = defaultUser;

  settingsFormat = pkgs.formats.yaml { };
in
{
  options = {
    services.opencloud = {
      enable = lib.mkEnableOption "OpenCloud";
      package = lib.mkPackageOption pkgs "opencloud" { };

      address = lib.mkOption {
        default = "127.0.0.1";
        description = "Web server bind address.";
        type = types.str;
      };

      environment = lib.mkOption {
        default = {
          OC_INSECURE = "true";
        };

        description = ''
          Extra environment variables to set for the service.

          Use this to set configuration that may affect multiple microservices.

          Set `OC_INSECURE = "false"` if you want OpenCloud to terminate TLS.

          Configuration provided here will override `settings`.
        '';

        example = {
          OC_INSECURE = "false";
          OC_LOG_LEVEL = "error";
        };

        type = types.attrsOf types.str;
      };

      environmentFile = lib.mkOption {
        default = null;

        description = ''
          An environment file as defined in {manpage}`systemd.exec(5)`.

          Use this to inject secrets, e.g. database or auth credentials out of band.

          Configuration provided here will override `settings` and `environment`.
        '';

        example = "/run/keys/opencloud.env";
        type = types.nullOr types.path;
      };

      group = lib.mkOption {
        default = defaultGroup;

        description = ''
          The group to run OpenCloud under.
          By default, a group named `${defaultGroup}` will be created.
        '';

        example = "mycloud";
        type = types.str;
      };

      idpWebPackage = lib.mkPackageOption pkgs [ "opencloud" "idp-web" ] { };

      port = lib.mkOption {
        default = 9200;
        description = "Web server port.";
        type = types.port;
      };

      settings = lib.mkOption {
        default = { };

        description = ''
          Additional YAML configuration for OpenCloud services.

          Every item in this attrset will be mapped to a .yaml file in /etc/opencloud.

          The possible config options are currently not well documented, see source code:
          https://github.com/opencloud-eu/opencloud/blob/main/pkg/config/config.go
        '';

        example = {
          proxy = {
            auto_provision_accounts = true;
            oidc.rewrite_well_known = true;

            role_assignment = {
              driver = "oidc";
              oidc_role_mapper.role_claim = "opencloud_roles";
            };
          };

          web.web.config.oidc.scope = "openid profile email opencloud_roles";
        };

        type = lib.types.attrsOf settingsFormat.type;
      };

      stateDir = lib.mkOption {
        default = "/var/lib/opencloud";
        description = "OpenCloud data directory.";
        type = types.str;
      };

      url = lib.mkOption {
        default = "https://localhost:9200";
        description = "Web interface root public URL, including scheme and port (if non-default).";
        example = "https://cloud.example.com";
        type = types.str;
      };

      user = lib.mkOption {
        default = defaultUser;

        description = ''
          The user to run OpenCloud as.
          By default, a user named `${defaultUser}` will be created whose home
          directory is [](#opt-services.opencloud.stateDir).
        '';

        example = "mycloud";
        type = types.str;
      };

      webPackage = lib.mkPackageOption pkgs [ "opencloud" "web" ] { };
    };
  };

  config = lib.mkIf cfg.enable {
    environment.etc =
      (lib.mapAttrs' (name: value: {
        name = "opencloud/${name}.yaml";
        value.source = settingsFormat.generate "${name}.yaml" value;
      }) cfg.settings)
      // {
        # ensure /etc/opencloud gets created, so we can provision the config
        "opencloud/.keep".text = "";
      };

    systemd = {
      services =
        let
          environment = {
            IDP_ASSET_PATH = "${cfg.idpWebPackage}/assets";
            OC_BASE_DATA_PATH = cfg.stateDir;
            OC_CONFIG_DIR = "/etc/opencloud";
            OC_URL = cfg.url;
            PROXY_HTTP_ADDR = "${cfg.address}:${toString cfg.port}";
            WEB_ASSET_CORE_PATH = "${cfg.webPackage}";
          }
          // cfg.environment;
          commonServiceConfig = {
            EnvironmentFile = lib.optional (cfg.environmentFile != null) cfg.environmentFile;
            LockPersonality = true;
            MemoryDenyWriteExecute = true;
            NoNewPrivileges = true;
            PrivateDevices = true;
            PrivateTmp = true;
            ProtectControlGroups = true;
            ProtectHome = true;
            ProtectKernelLogs = true;
            ProtectKernelModules = true;
            ProtectKernelTunables = true;
            ProtectSystem = "strict";

            RestrictAddressFamilies = [
              "AF_UNIX"
              "AF_INET"
              "AF_INET6"
            ];

            RestrictNamespaces = true;
            RestrictRealtime = true;
            RestrictSUIDSGID = true;
            SystemCallArchitectures = "native";
          };
        in
        {
          opencloud = {
            inherit environment;
            after = [ "network.target" ];
            description = "OpenCloud - a secure and private way to store, access, and share your files";

            restartTriggers = lib.mapAttrsToList (
              name: _: config.environment.etc."opencloud/${name}.yaml".source
            ) cfg.settings;

            serviceConfig = {
              ExecStart = "${lib.getExe cfg.package} server";
              Group = cfg.group;
              ReadWritePaths = [ cfg.stateDir ];
              Restart = "always";
              Type = "simple";
              User = cfg.user;
              WorkingDirectory = cfg.stateDir;
            }
            // commonServiceConfig;

            wantedBy = [ "multi-user.target" ];
          };

          opencloud-init-config = lib.mkIf (cfg.settings.opencloud or { } == { }) {
            inherit environment;
            before = [ "opencloud.service" ];
            description = "Provision initial OpenCloud config";
            path = [ cfg.package ];

            script = ''
              set -x
              config="''${OC_CONFIG_DIR}/opencloud.yaml"
              if [ ! -e "$config" ]; then
                echo "Provisioning initial OpenCloud config..."
                opencloud init --insecure "''${OC_INSECURE:false}" --config-path "''${OC_CONFIG_DIR}"
                chown ${cfg.user}:${cfg.group} "$config"
              fi
            '';

            serviceConfig = {
              ReadWritePaths = [ "/etc/opencloud" ];
              Type = "oneshot";
            }
            // commonServiceConfig;

            wantedBy = [ "multi-user.target" ];
          };
        };
    };

    systemd.tmpfiles.settings."10-opencloud" = {
      ${cfg.stateDir}.d = {
        inherit (cfg) user group;
        mode = "0750";
      };

      "${cfg.stateDir}/idm".d = {
        inherit (cfg) user group;
        mode = "0750";
      };
    };

    users.groups = lib.mkIf (cfg.group == defaultGroup) { ${defaultGroup} = { }; };

    users.users.${defaultUser} = lib.mkIf (cfg.user == defaultUser) {
      createHome = true;
      description = "OpenCloud daemon user";
      group = cfg.group;
      home = cfg.stateDir;
      isSystemUser = true;
    };
  };

  meta = {
    doc = ./opencloud.md;

    maintainers = with lib.maintainers; [
      christoph-heiss
      k900
    ];
  };
}

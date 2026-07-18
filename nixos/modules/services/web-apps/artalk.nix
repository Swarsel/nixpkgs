{
  config,
  lib,
  pkgs,
  utils,
  ...
}:
let
  cfg = config.services.artalk;
  settingsFormat = pkgs.formats.json { };
in
{

  options = {
    services.artalk = {
      enable = lib.mkEnableOption "artalk, a comment system";
      package = lib.mkPackageOption pkgs "artalk" { };

      allowModify = lib.mkOption {
        default = true;
        description = "allow Artalk store the settings to config file persistently";
        type = lib.types.bool;
      };

      configFile = lib.mkOption {
        default = "/etc/artalk/config.yml";
        description = "Artalk config file path. If it is not exist, Artalk will generate one.";
        type = lib.types.str;
      };

      group = lib.mkOption {
        default = "artalk";
        description = "Artalk group name.";
        type = lib.types.str;
      };

      settings = lib.mkOption {
        default = { };

        description = ''
          The artalk configuration.

          If you set allowModify to true, Artalk will be able to store the settings in the config file persistently. This section's content will update in the config file after the service restarts.

          Options containing secret data should be set to an attribute set
          containing the attribute `_secret` - a string pointing to a file
          containing the value the option should be set to.
        '';

        type = lib.types.submodule {
          options = {
            host = lib.mkOption {
              default = "0.0.0.0";

              description = ''
                Artalk server listen host
              '';

              type = lib.types.str;
            };

            port = lib.mkOption {
              default = 23366;

              description = ''
                Artalk server listen port
              '';

              type = lib.types.port;
            };
          };

          freeformType = settingsFormat.type;
        };
      };

      user = lib.mkOption {
        default = "artalk";
        description = "Artalk user name.";
        type = lib.types.str;
      };

      workdir = lib.mkOption {
        default = "/var/lib/artalk";
        description = "Artalk working directory";
        type = lib.types.str;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];

    systemd.services.artalk = {
      after = [ "network.target" ];

      preStart = ''
        umask 0077
        ${utils.genJqSecretsReplacementSnippet cfg.settings "/run/artalk/new"}
      ''
      + (
        if cfg.allowModify then
          ''
            [ -e "${cfg.configFile}" ] || ${lib.getExe cfg.package} gen config "${cfg.configFile}"
            cat "${cfg.configFile}" | ${lib.getExe pkgs.yj} > "/run/artalk/old"
            ${lib.getExe pkgs.jq} -s '.[0] * .[1]' "/run/artalk/old" "/run/artalk/new" > "/run/artalk/result"
            cat "/run/artalk/result" | ${lib.getExe pkgs.yj} -r > "${cfg.configFile}"
            rm /run/artalk/{old,new,result}
          ''
        else
          ''
            cat /run/artalk/new | ${lib.getExe pkgs.yj} -r > "${cfg.configFile}"
            rm /run/artalk/new
          ''
      );

      serviceConfig = {
        AmbientCapabilities = [ "CAP_NET_BIND_SERVICE" ];
        ConfigurationDirectory = [ "artalk" ];
        ExecStart = "${lib.getExe cfg.package} server --config ${cfg.configFile} --workdir ${cfg.workdir} --host ${cfg.settings.host} --port ${toString cfg.settings.port}";
        Group = cfg.group;
        ProtectHome = "yes";
        Restart = "on-failure";
        RestartSec = "5s";
        RuntimeDirectory = [ "artalk" ];
        StateDirectory = [ "artalk" ];
        Type = "simple";
        User = cfg.user;
      };

      wantedBy = [ "multi-user.target" ];
    };

    users.groups.artalk = lib.optionalAttrs (cfg.group == "artalk") { };

    users.users.artalk = lib.optionalAttrs (cfg.user == "artalk") {
      description = "artalk user";
      group = cfg.group;
      isSystemUser = true;
    };
  };

  meta = {
    maintainers = with lib.maintainers; [ moraxyc ];
  };
}

{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.thelounge;
  dataDir = "/var/lib/thelounge";
  configJsData =
    "module.exports = " + builtins.toJSON ({ inherit (cfg) public port; } // cfg.extraConfig);
  pluginManifest = {
    dependencies = builtins.listToAttrs (
      map (pkg: {
        name = getName pkg;
        value = getVersion pkg;
      }) cfg.plugins
    );
  };
  plugins =
    pkgs.runCommand "thelounge-plugins"
      {
        preferLocalBuild = true;
      }
      ''
        mkdir -p $out/node_modules
        echo ${escapeShellArg (builtins.toJSON pluginManifest)} >> $out/package.json
        ${concatMapStringsSep "\n" (pkg: ''
          ln -s ${pkg}/lib/node_modules/${getName pkg} $out/node_modules/${getName pkg}
        '') cfg.plugins}
      '';
in
{
  imports = [
    (mkRemovedOptionModule [
      "services"
      "thelounge"
      "private"
    ] "The option was renamed to `services.thelounge.public` to follow upstream changes.")
  ];

  options.services.thelounge = {
    enable = mkEnableOption "The Lounge web IRC client";
    package = mkPackageOption pkgs "thelounge" { };

    extraConfig = mkOption {
      default = { };

      description = ''
        The Lounge's {file}`config.js` contents as attribute set (will be
        converted to JSON to generate the configuration file).

        The options defined here will be merged to the default configuration file.
        Note: In case of duplicate configuration, options from {option}`extraConfig` have priority.

        Documentation: <https://thelounge.chat/docs/server/configuration>
      '';

      example = literalExpression ''
        {
          reverseProxy = true;
          defaults = {
            name = "Your Network";
            host = "localhost";
            port = 6697;
          };
        }
      '';

      type = types.attrs;
    };

    plugins = mkOption {
      default = [ ];

      description = ''
        The Lounge plugins to install. Plugins can be found in
        `pkgs.theLoungePlugins.plugins` and `pkgs.theLoungePlugins.themes`.
      '';

      example = literalExpression "[ pkgs.theLoungePlugins.themes.solarized ]";
      type = types.listOf types.package;
    };

    port = mkOption {
      default = 9000;
      description = "TCP port to listen on for http connections.";
      type = types.port;
    };

    public = mkOption {
      default = false;

      description = ''
        Make your The Lounge instance public.
        Setting this to `false` will require you to configure user
        accounts by using the ({command}`thelounge`) command or by adding
        entries in {file}`${dataDir}/users`. You might need to restart
        The Lounge after making changes to the state directory.
      '';

      type = types.bool;
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];

    systemd.services.thelounge = {
      after = [ "network-online.target" ];
      description = "The Lounge web IRC client";
      environment.THELOUNGE_PACKAGES = mkIf (cfg.plugins != [ ]) "${plugins}";
      preStart = "ln -sf ${pkgs.writeText "config.js" configJsData} ${dataDir}/config.js";

      serviceConfig = {
        ExecStart = "${getExe cfg.package} start";
        StateDirectory = baseNameOf dataDir;
        User = "thelounge";
      };

      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
    };

    users.groups.thelounge = { };

    users.users.thelounge = {
      description = "The Lounge service user";
      group = "thelounge";
      isSystemUser = true;
    };
  };

  meta = {
    maintainers = with lib.maintainers; [ winter ];
  };
}

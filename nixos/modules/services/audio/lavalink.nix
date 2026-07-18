{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib)
    mkOption
    mkEnableOption
    mkIf
    types
    ;

  cfg = config.services.lavalink;

  format = pkgs.formats.yaml { };
in

{
  options.services.lavalink = {
    enable = mkEnableOption "Lavalink";
    package = lib.mkPackageOption pkgs "lavalink" { };

    address = mkOption {
      default = "0.0.0.0";

      description = ''
        The network address to bind to.
      '';

      example = "127.0.0.1";
      type = types.str;
    };

    enableHttp2 = mkEnableOption "HTTP/2 support";

    environmentFile = mkOption {
      default = null;

      description = ''
        Add custom environment variables from a file.
        See <https://lavalink.dev/configuration/index.html#example-environment-variables> for the full documentation.
      '';

      example = "/run/secrets/lavalink/passwordEnvFile";
      type = types.nullOr types.str;
    };

    extraConfig = mkOption {
      default = { };

      description = ''
        Configuration to write to {file}`application.yml`.
        See <https://lavalink.dev/configuration/#example-applicationyml> for the full documentation.

        Individual configuration parameters can be overwritten using environment variables.
        See <https://lavalink.dev/configuration/#example-environment-variables> for more information.
      '';

      example = lib.literalExpression ''
        {
          lavalink.server = {
            sources.twitch = true;

            filters.volume = true;
          };

          logging.file.path = "./logs/";
        }
      '';

      type = types.submodule { freeformType = format.type; };
    };

    group = mkOption {
      default = "lavalink";

      description = ''
        The group of the service.
      '';

      example = "medias";
      type = types.str;
    };

    home = mkOption {
      default = "/var/lib/lavalink";

      description = ''
        The home directory for lavalink.
      '';

      example = "/home/lavalink";
      type = types.str;
    };

    jvmArgs = mkOption {
      default = "-Xmx4G";

      description = ''
        Set custom JVM arguments.
      '';

      example = "-Djava.io.tmpdir=/var/lib/lavalink/tmp -Xmx6G";
      type = types.str;
    };

    openFirewall = mkOption {
      default = false;

      description = ''
        Whether to expose the port to the network.
      '';

      example = true;
      type = types.bool;
    };

    password = mkOption {
      default = null;

      description = ''
        The password for Lavalink's authentication in plain text.
      '';

      example = "s3cRe!p4SsW0rD";
      type = types.nullOr types.str;
    };

    plugins = mkOption {
      default = [ ];

      description = ''
        A list of plugins for lavalink.
      '';

      example = lib.literalExpression ''
        [
          {
            dependency = "dev.lavalink.youtube:youtube-plugin:1.8.0";
            repository = "https://maven.lavalink.dev/snapshots";
            hash = lib.fakeHash;
            configName = "youtube";
            extraConfig = {
              enabled = true;
              allowSearch = true;
              allowDirectVideoIds = true;
              allowDirectPlaylistIds = true;
            };
          }
        ]
      '';

      type = types.listOf (
        types.submodule {
          options = {
            configName = mkOption {
              default = null;

              description = ''
                The name of the plugin to use as the key for the plugin configuration.
              '';

              example = "youtube";
              type = types.nullOr types.str;
            };

            dependency = mkOption {
              description = ''
                The coordinates of the plugin.
              '';

              example = "dev.lavalink.youtube:youtube-plugin:1.8.0";
              type = types.str;
            };

            extraConfig = mkOption {
              default = { };

              description = ''
                The configuration for the plugin.

                The {option}`services.lavalink.plugins.*.configName` option must be set.
              '';

              type = types.submodule { freeformType = format.type; };
            };

            hash = mkOption {
              description = ''
                The hash of the plugin.
              '';

              example = lib.fakeHash;
              type = types.str;
            };

            repository = mkOption {
              default = "https://maven.lavalink.dev/releases";

              description = ''
                The plugin repository. Defaults to the lavalink releases repository.

                To use the snapshots repository, use <https://maven.lavalink.dev/snapshots> instead
              '';

              example = "https://maven.example.com/releases";
              type = types.str;
            };
          };
        }
      );
    };

    port = mkOption {
      default = 2333;

      description = ''
        The port that Lavalink will use.
      '';

      example = 4567;
      type = types.port;
    };

    user = mkOption {
      default = "lavalink";

      description = ''
        The user of the service.
      '';

      example = "root";
      type = types.str;
    };
  };

  config =
    let
      pluginSymlinks = lib.concatStringsSep "\n" (
        map (
          pluginCfg:
          let
            pluginParts = lib.match ''^(.*?:(.*?):)([0-9]+\.[0-9]+\.[0-9]+)$'' pluginCfg.dependency;

            pluginWebPath = lib.replaceStrings [ "." ":" ] [ "/" "/" ] (lib.elemAt pluginParts 0);

            pluginFileName = lib.elemAt pluginParts 1;
            pluginVersion = lib.elemAt pluginParts 2;

            pluginFile = "${pluginFileName}-${pluginVersion}.jar";
            pluginUrl = "${pluginCfg.repository}/${pluginWebPath}${pluginVersion}/${pluginFile}";

            plugin = pkgs.fetchurl {
              inherit (pluginCfg) hash;
              url = pluginUrl;
            };
          in
          "ln -sf ${plugin} ${cfg.home}/plugins/${pluginFile}"
        ) cfg.plugins
      );

      pluginExtraConfigs = builtins.listToAttrs (
        map (pluginConfig: lib.attrsets.nameValuePair pluginConfig.configName pluginConfig.extraConfig) (
          lib.lists.filter (pluginCfg: pluginCfg.configName != null) cfg.plugins
        )
      );

      config = lib.attrsets.recursiveUpdate cfg.extraConfig {
        lavalink.plugins = (
          map (
            pluginConfig:
            removeAttrs pluginConfig [
              "name"
              "extraConfig"
              "hash"
            ]
          ) cfg.plugins
        );

        plugins = pluginExtraConfigs;

        server = {
          inherit (cfg) port address;
          http2.enabled = cfg.enableHttp2;
        };
      };

      configWithPassword = lib.attrsets.recursiveUpdate config (
        lib.attrsets.optionalAttrs (cfg.password != null) { lavalink.server.password = cfg.password; }
      );

      configFile = format.generate "application.yml" configWithPassword;
    in
    mkIf cfg.enable {
      assertions = [
        {
          assertion =
            !(lib.lists.any (
              pluginCfg: pluginCfg.extraConfig != { } && pluginCfg.configName == null
            ) cfg.plugins);

          message = "Plugins with extra configuration need to have the `configName` attribute defined";
        }
      ];

      networking.firewall.allowedTCPPorts = mkIf cfg.openFirewall [ cfg.port ];

      systemd.services.lavalink = {
        after = [
          "syslog.target"
          "network.target"
        ];

        description = "Lavalink Service";

        script = ''
          ${pluginSymlinks}

          ln -sf ${configFile} ${cfg.home}/application.yml
          export _JAVA_OPTIONS="${cfg.jvmArgs}"

          ${lib.getExe cfg.package}
        '';

        serviceConfig = {
          EnvironmentFile = cfg.environmentFile;
          Group = cfg.group;
          Restart = "on-failure";
          Type = "simple";
          User = cfg.user;
          WorkingDirectory = cfg.home;
        };

        wantedBy = [ "multi-user.target" ];
      };

      systemd.tmpfiles.settings."10-lavalink" =
        let
          dirConfig = {
            inherit (cfg) user group;
            mode = "0700";
          };
        in
        {
          ${cfg.home}.d = dirConfig;
          "${cfg.home}/plugins".d = mkIf (cfg.plugins != [ ]) dirConfig;
        };

      users.groups = mkIf (cfg.group == "lavalink") { lavalink = { }; };

      users.users = mkIf (cfg.user == "lavalink") {
        lavalink = {
          inherit (cfg) home;
          description = "The user for the Lavalink server";
          group = "lavalink";
          isSystemUser = true;
        };
      };
    };
}

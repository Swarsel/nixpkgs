{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.bluemap;
  format = pkgs.formats.hocon { };

  coreConfig = format.generate "core.conf" cfg.coreSettings;
  webappConfig = format.generate "webapp.conf" cfg.webappSettings;
  webserverConfig = format.generate "webserver.conf" cfg.webserverSettings;

  mapsFolder = pkgs.linkFarm "maps" (
    lib.attrsets.mapAttrs' (
      name: value: lib.nameValuePair "${name}.conf" (format.generate "${name}.conf" value)
    ) cfg.maps
  );

  storageFolder = pkgs.linkFarm "storage" (
    lib.attrsets.mapAttrs' (
      name: value: lib.nameValuePair "${name}.conf" (format.generate "${name}.conf" value)
    ) cfg.storage
  );

  configFolder = pkgs.linkFarm "bluemap-config" {
    "core.conf" = coreConfig;
    "maps" = mapsFolder;
    "packs" = pkgs.linkFarm "packs" cfg.packs;
    "storages" = storageFolder;
    "webapp.conf" = webappConfig;
    "webserver.conf" = webserverConfig;
  };

  inherit (lib) mkOption;
in
{
  imports = [
    (lib.mkRenamedOptionModule
      [ "services" "bluemap" "resourcepacks" ]
      [ "services" "bluemap" "packs" ]
    )
    (lib.mkRenamedOptionModule [ "services" "bluemap" "addons" ] [ "services" "bluemap" "packs" ])
  ];

  options.services.bluemap = {
    enable = lib.mkEnableOption "bluemap";

    coreSettings = mkOption {
      description = "Settings for the core.conf file, [see upstream docs](https://github.com/BlueMap-Minecraft/BlueMap/blob/master/BlueMapCommon/src/main/resources/de/bluecolored/bluemap/config/core.conf).";

      type = lib.types.submodule {
        options = {
          data = mkOption {
            default = "/var/lib/bluemap";
            description = "Folder for where bluemap stores its data";
            type = lib.types.path;
          };

          metrics = lib.mkEnableOption "Sending usage metrics containing the version of bluemap in use";
        };

        freeformType = format.type;
      };
    };

    defaultWorld = mkOption {
      description = ''
        The world used by the default map ruleset.
        If you configure your own maps you do not need to set this.
      '';

      example = lib.literalExpression "\${config.services.minecraft.dataDir}/world";
      type = lib.types.path;
    };

    enableNginx = mkOption {
      default = true;
      description = "Enable configuring a virtualHost for serving the bluemap webapp";
      type = lib.types.bool;
    };

    enableRender = mkOption {
      default = true;
      description = "Enable rendering";
      type = lib.types.bool;
    };

    eula = mkOption {
      default = false;

      description = ''
        By changing this option to true you confirm that you own a copy of minecraft Java Edition,
        and that you agree to minecrafts EULA.
      '';

      type = lib.types.bool;
    };

    host = mkOption {
      description = "Domain on which nginx will serve the bluemap webapp";
      type = lib.types.str;
    };

    maps = mkOption {
      default = {
        "end" = {
          ambient-light = 0.6;
          cave-detection-ocean-floor = -5;
          remove-caves-below-y = -10000;
          sky-color = "#080010";
          sorting = 200;
          void-color = "#080010";
          world = "${cfg.defaultWorld}/DIM1";
          world-sky-light = 0;
        };

        "nether" = {
          ambient-light = 0.6;
          cave-detection-ocean-floor = -5;
          cave-detection-uses-block-light = true;
          max-y = 90;
          remove-caves-below-y = -10000;
          sky-color = "#290000";
          sorting = 100;
          void-color = "#150000";
          world = "${cfg.defaultWorld}/DIM-1";
          world-sky-light = 0;
        };

        "overworld" = {
          ambient-light = 0.1;
          cave-detection-ocean-floor = -5;
          world = "${cfg.defaultWorld}";
        };
      };

      defaultText = lib.literalExpression ''
        {
          "overworld" = {
            world = "''${cfg.defaultWorld}";
            ambient-light = 0.1;
            cave-detection-ocean-floor = -5;
          };

          "nether" = {
            world = "''${cfg.defaultWorld}/DIM-1";
            sorting = 100;
            sky-color = "#290000";
            void-color = "#150000";
            ambient-light = 0.6;
            world-sky-light = 0;
            remove-caves-below-y = -10000;
            cave-detection-ocean-floor = -5;
            cave-detection-uses-block-light = true;
            max-y = 90;
          };

          "end" = {
            world = "''${cfg.defaultWorld}/DIM1";
            sorting = 200;
            sky-color = "#080010";
            void-color = "#080010";
            ambient-light = 0.6;
            world-sky-light = 0;
            remove-caves-below-y = -10000;
            cave-detection-ocean-floor = -5;
          };
        };
      '';

      description = ''
        Settings for files in `maps/`.
        If you define anything here you must define everything yourself.
        See the default for an example with good options for the different world types.
        For valid values [consult upstream docs](https://github.com/BlueMap-Minecraft/BlueMap/blob/master/BlueMapCommon/src/main/resources/de/bluecolored/bluemap/config/maps/map.conf).
      '';

      type = lib.types.attrsOf (
        lib.types.submodule {
          options = {
            world = lib.mkOption {
              description = "Path to world folder containing the dimension to render";
              type = lib.types.path;
            };
          };

          freeformType = format.type;
        }
      );
    };

    onCalendar = mkOption {
      default = "*-*-* 03:10:00";

      description = ''
        How often to trigger rendering the map,
        in the format of a systemd timer onCalendar configuration.
        See {manpage}`systemd.timer(5)`.
      '';

      type = lib.types.str;
    };

    packs = mkOption {
      default = { };

      description = ''
        A set of resourcepacks, datapacks, and mods to extract resources from,
        loaded in alphabetical order.
      '';

      type = lib.types.attrsOf lib.types.pathInStore;
    };

    storage = mkOption {
      default = {
        "file" = {
          root = "${cfg.webRoot}/maps";
        };
      };

      defaultText = lib.literalExpression ''
        {
          "file" = {
            root = "''${config.services.bluemap.webRoot}/maps";
          };
        }
      '';

      description = ''
        Where the rendered map will be stored.
        Unless you are doing something advanced you should probably leave this alone and configure webRoot instead.
        [See upstream docs](https://github.com/BlueMap-Minecraft/BlueMap/tree/master/BlueMapCommon/src/main/resources/de/bluecolored/bluemap/config/storages)
      '';

      type = lib.types.attrsOf (
        lib.types.submodule {
          options = {
            storage-type = mkOption {
              default = "FILE";
              description = "Type of storage config";

              type = lib.types.enum [
                "FILE"
                "SQL"
              ];
            };
          };

          freeformType = format.type;
        }
      );
    };

    webRoot = mkOption {
      default = "/var/lib/bluemap/web";
      description = "The directory for saving and serving the webapp and the maps";
      type = lib.types.path;
    };

    webappSettings = mkOption {
      default = {
        enabled = true;
        webroot = cfg.webRoot;
      };

      defaultText = lib.literalExpression ''
        {
          enabled = true;
          webroot = config.services.bluemap.webRoot;
        }
      '';

      description = "Settings for the webapp.conf file, see [upstream docs](https://github.com/BlueMap-Minecraft/BlueMap/blob/master/BlueMapCommon/src/main/resources/de/bluecolored/bluemap/config/webapp.conf).";

      type = lib.types.submodule {
        freeformType = format.type;
      };
    };

    webserverSettings = mkOption {
      default = { };

      description = ''
        Settings for the webserver.conf file, usually not required.
        [See upstream docs](https://github.com/BlueMap-Minecraft/BlueMap/blob/master/BlueMapCommon/src/main/resources/de/bluecolored/bluemap/config/webserver.conf).
      '';

      type = lib.types.submodule {
        options = {
          enabled = mkOption {
            default = false;

            description = ''
              Enable bluemap's built-in webserver.
              Disabled by default in nixos for use of nginx directly.
            '';

            type = lib.types.bool;
          };
        };

        freeformType = format.type;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = config.services.bluemap.eula;

        message = ''
          You have enabled bluemap but have not accepted minecraft's EULA.
          You can achieve this through setting `services.bluemap.eula = true`
        '';
      }
    ];

    services.bluemap.coreSettings.accept-download = cfg.eula;

    services.nginx.virtualHosts = lib.mkIf cfg.enableNginx {
      "${cfg.host}" = {
        locations = {
          "@empty".return = "204";

          "~* ^/maps/[^/]*/tiles/".extraConfig = ''
            error_page 404 = @empty;
            gzip_static always;
          '';
        };

        root = config.services.bluemap.webRoot;
      };
    };

    systemd.services."render-bluemap-maps" = lib.mkIf cfg.enableRender {
      script = ''
        ${lib.getExe pkgs.bluemap} -c ${configFolder} -gs -r
      '';

      serviceConfig = {
        Group = "nginx";
        Type = "oneshot";
        UMask = "026";
      };
    };

    systemd.timers."render-bluemap-maps" = lib.mkIf cfg.enableRender {
      timerConfig = {
        OnCalendar = cfg.onCalendar;
        Persistent = true;
        Unit = "render-bluemap-maps.service";
      };

      wantedBy = [ "timers.target" ];
    };
  };

  meta = {
    maintainers = with lib.maintainers; [
      dandellion
      h7x4
    ];
  };
}

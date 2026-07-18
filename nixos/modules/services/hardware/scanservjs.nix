{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.scanservjs;
  settings = {
    convert = lib.getExe' pkgs.imagemagick "convert";
    # it defaults to config/devices.json, but "config" dir doesn't exist by default and scanservjs doesn't create it
    devicesPath = "devices.json";
    scanimage = lib.getExe' config.hardware.sane.backends-package "scanimage";
    tesseract = lib.getExe pkgs.tesseract;
  }
  // cfg.settings;
  settingsFormat = pkgs.formats.json { };

  leafs =
    attrs:
    builtins.concatLists (
      lib.mapAttrsToList (k: v: if builtins.isAttrs v then leafs v else [ v ]) attrs
    );

  package = pkgs.scanservjs;

  configFile = pkgs.writeText "config.local.js" ''
    /* eslint-disable no-unused-vars */
    module.exports = {
      afterConfig(config) {
        ${builtins.concatStringsSep "" (
          leafs (
            lib.mapAttrsRecursive (path: val: ''
              ${builtins.concatStringsSep "." path} = ${builtins.toJSON val};
            '') { config = settings; }
          )
        )}
        ${cfg.extraConfig}
      },

      afterDevices(devices) {
        ${cfg.extraDevicesConfig}
      },

      async afterScan(fileInfo) {
        ${cfg.runAfterScan}
      },

      actions: [
        ${builtins.concatStringsSep ",\n" cfg.extraActions}
      ],
    };
  '';

in
{
  options.services.scanservjs = {
    enable = lib.mkEnableOption "scanservjs";

    extraActions = lib.mkOption {
      default = [ ];
      description = "Actions to add to config.local.js's `actions`.";
      type = lib.types.listOf lib.types.lines;
    };

    extraConfig = lib.mkOption {
      default = "";

      description = ''
        Extra code to add to config.local.js's `afterConfig`.
      '';

      type = lib.types.lines;
    };

    extraDevicesConfig = lib.mkOption {
      default = "";

      description = ''
        Extra code to add to config.local.js's `afterDevices`.
      '';

      type = lib.types.lines;
    };

    runAfterScan = lib.mkOption {
      default = "";

      description = ''
        Extra code to add to config.local.js's `afterScan`.
      '';

      type = lib.types.lines;
    };

    settings = lib.mkOption {
      default = { };

      description = ''
        Config to set in config.local.js's `afterConfig`.
      '';

      type = lib.types.submodule {
        options.host = lib.mkOption {
          default = "127.0.0.1";
          description = "The IP to listen on.";
          type = lib.types.str;
        };

        options.port = lib.mkOption {
          default = 8080;
          description = "The port to listen on.";
          type = lib.types.port;
        };

        freeformType = settingsFormat.type;
      };
    };

    stateDir = lib.mkOption {
      default = "/var/lib/scanservjs";

      description = ''
        State directory for scanservjs.
      '';

      type = lib.types.str;
    };
  };

  config = lib.mkIf cfg.enable {
    hardware.sane.enable = true;

    systemd.services.scanservjs = {
      after = [ "network.target" ];
      description = "scanservjs";

      environment = {
        LD_LIBRARY_PATH = "/etc/sane-libs";
        NIX_SCANSERVJS_CONFIG_PATH = configFile;
        SANE_CONFIG_DIR = "/etc/sane-config";
      };

      # yes, those paths are configurable, but the config option isn't always used...
      # a lot of the time scanservjs just takes those from PATH
      path = with pkgs; [
        coreutils
        config.hardware.sane.backends-package
        imagemagick
        tesseract
      ];

      serviceConfig = {
        ExecStart = lib.getExe package;
        Group = "scanservjs";
        Restart = "always";
        User = "scanservjs";
        WorkingDirectory = cfg.stateDir;
      };

      wantedBy = [ "multi-user.target" ];
    };

    systemd.tmpfiles.rules = [
      "d ${cfg.stateDir}/data 0755 scanservjs scanservjs - -"
      "d ${cfg.stateDir}/data/preview 0755 scanservjs scanservjs - -"
      "L+ ${cfg.stateDir}/data/preview/default.jpg - - - - ${package}/lib/data/preview/default.jpg"
    ];

    users.groups.scanservjs = { };

    users.users.scanservjs = {
      createHome = true;

      extraGroups = [
        "scanner"
        "lp"
      ];

      group = "scanservjs";
      home = cfg.stateDir;
      isSystemUser = true;
    };
  };
}

{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib)
    types
    mkDefault
    mkOption
    mkPackageOption
    ;

  json = pkgs.formats.json { };

  cfg = config.services.zenohd;

in
{
  options = {
    services.zenohd = {
      enable = lib.mkEnableOption "Zenoh daemon.";
      package = mkPackageOption pkgs "zenoh" { };

      backends = mkOption {
        default = [ ];
        description = "Storage backend packages to add to zenohd search paths.";

        example = lib.literalExpression ''
          [ pkgs.zenoh-backend-rocksdb ]
        '';

        type = with types; listOf package;
      };

      env = mkOption {
        default = { };

        description = ''
          Set environment variables consumed by zenohd and its plugins.
        '';

        type = with types; attrsOf str;
      };

      extraOptions = mkOption {
        default = [ ];
        description = "Extra command line options for zenohd.";
        type = with types; listOf str;
      };

      home = mkOption {
        default = "/var/lib/zenoh";
        description = "Base directory for zenohd related files defined via ZENOH_HOME.";
        type = types.str;
      };

      plugins = mkOption {
        default = [ ];
        description = "Plugin packages to add to zenohd search paths.";

        example = lib.literalExpression ''
          [ pkgs.zenoh-plugin-mqtt ]
        '';

        type = with types; listOf package;
      };

      settings = mkOption {
        default = { };

        description = ''
          Config options for `zenoh.json5` configuration file.

          See <https://github.com/eclipse-zenoh/zenoh/blob/main/DEFAULT_CONFIG.json5>
          for more information.
        '';

        type = types.submodule {
          freeformType = json.type;
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {
    services.zenohd = {
      env.ZENOH_HOME = cfg.home;

      settings = {
        plugins.storage_manager.backend_search_dirs = mkDefault (
          map (x: "${lib.getLib x}/lib") cfg.backends
        );

        plugins_loading = {
          enabled = mkDefault true;

          search_dirs = mkDefault (
            (map (x: "${lib.getLib x}/lib") cfg.plugins) ++ [ "${lib.getLib cfg.package}/lib" ]
          ); # needed for internal plugins
        };
      };
    };

    systemd.services.zenohd =
      let
        cfgFile = json.generate "zenohd.json" cfg.settings;

      in
      {
        after = [ "network-online.target" ];
        environment = cfg.env;

        serviceConfig = {
          ExecStart =
            "${lib.getExe cfg.package} -c ${cfgFile} " + (lib.concatStringsSep " " cfg.extraOptions);

          Group = "zenohd";
          Type = "simple";
          User = "zenohd";
        };

        wantedBy = [ "multi-user.target" ];
        wants = [ "network-online.target" ];
      };

    systemd.tmpfiles.rules = [ "d ${cfg.home} 750 zenohd zenohd -" ];

    users = {
      groups.zenohd = { };

      users.zenohd = {
        description = "Zenoh daemon user";
        group = "zenohd";
        isSystemUser = true;
      };
    };
  };
}

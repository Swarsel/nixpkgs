{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.goeland;
  tomlFormat = pkgs.formats.toml { };
in
{
  options.services.goeland = {
    enable = lib.mkEnableOption "goeland, an alternative to rss2email";

    schedule = lib.mkOption {
      default = "12h";
      description = "How often to run goeland, in systemd time format.";
      example = "Mon, 00:00:00";
      type = lib.types.str;
    };

    settings = lib.mkOption {
      default = { };

      description = ''
        Configuration of goeland.
        See the [example config file](https://github.com/slurdge/goeland/blob/master/cmd/asset/config.default.toml) for the available options.
      '';

      type = tomlFormat.type;
    };

    stateDir = lib.mkOption {
      default = "/var/lib/goeland";

      description = ''
        The data directory for goeland where the database will reside if using the unseen filter.
        If left as the default value this directory will automatically be created before the goeland
        server starts, otherwise you are responsible for ensuring the directory exists with
        appropriate ownership and permissions.
      '';

      type = lib.types.path;
    };
  };

  config = lib.mkIf cfg.enable {
    services.goeland.settings.database = "${cfg.stateDir}/goeland.db";

    systemd.services.goeland = {
      serviceConfig =
        let
          confFile = tomlFormat.generate "config.toml" cfg.settings;
        in
        lib.mkMerge [
          {
            ExecStart = "${pkgs.goeland}/bin/goeland run -c ${confFile}";
            Group = "goeland";
            User = "goeland";
          }
          (lib.mkIf (cfg.stateDir == "/var/lib/goeland") {
            StateDirectory = "goeland";
            StateDirectoryMode = "0750";
          })
        ];

      startAt = cfg.schedule;
    };

    users.groups.goeland = { };

    users.users.goeland = {
      description = "goeland user";
      group = "goeland";
      isSystemUser = true;
    };

    warnings = lib.optionals (lib.hasAttr "password" cfg.settings.email) [
      ''
        It is not recommended to set the "services.goeland.settings.email.password"
        option as it will be in cleartext in the Nix store.
        Please use "services.goeland.settings.email.password_file" instead.
      ''
    ];
  };

  meta.maintainers = with lib.maintainers; [ sweenu ];
}

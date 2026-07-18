{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.hardware.pommed;
  defaultConf = "${pkgs.pommed_light}/etc/pommed.conf.mactel";
in
{

  options = {

    services.hardware.pommed = {

      enable = lib.mkOption {
        default = false;

        description = ''
          Whether to use the pommed tool to handle Apple laptop
          keyboard hotkeys.
        '';

        type = lib.types.bool;
      };

      configFile = lib.mkOption {
        default = null;

        description = ''
          The path to the {file}`pommed.conf` file. Leave
          to null to use the default config file
          ({file}`/etc/pommed.conf.mactel`). See the
          files {file}`/etc/pommed.conf.mactel` and
          {file}`/etc/pommed.conf.pmac` for examples to
          build on.
        '';

        type = lib.types.nullOr lib.types.path;
      };
    };

  };

  config = lib.mkIf cfg.enable {
    environment.etc."pommed.conf".source =
      if cfg.configFile == null then defaultConf else cfg.configFile;

    environment.systemPackages = [
      pkgs.polkit
      pkgs.pommed_light
    ];

    systemd.services.pommed = {
      description = "Pommed Apple Hotkeys Daemon";
      serviceConfig.ExecStart = "${lib.getExe pkgs.pommed_light} -f";
      wantedBy = [ "multi-user.target" ];
    };
  };
}

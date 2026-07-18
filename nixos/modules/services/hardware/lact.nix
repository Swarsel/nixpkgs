{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.lact;
  configFormat = pkgs.formats.yaml { };
  configFile = configFormat.generate "lact-config.yaml" cfg.settings;
in
{
  options.services.lact = {
    enable = lib.mkEnableOption null // {
      description = ''
        Whether to enable LACT, a tool for monitoring, configuring and overclocking GPUs.

        ::: {.note}
        If you are on an AMD GPU, it is recommended to enable overdrive mode by using
        `hardware.amdgpu.overdrive.enable = true;` in your configuration.
        See [LACT wiki](https://github.com/ilya-zlobintsev/LACT/wiki/Overclocking-(AMD)) for more information.
        :::
      '';
    };

    package = lib.mkPackageOption pkgs "lact" { };

    settings = lib.mkOption {
      default = { };

      description = ''
        Settings for LACT.

        The easiest method of acquiring the settings is to delete
        {file}`/etc/lact/config.yaml`, enter your settings and look
        at the file.

        ::: {.note}
        When `settings` is populated, the config file will be a symbolic link
        and thus LACT daemon will not be able to modify it through the GUI.
        :::
      '';

      type = lib.types.submodule {
        freeformType = configFormat.type;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    environment.etc."lact/config.yaml" = lib.mkIf (cfg.settings != { }) {
      source = configFile;
    };

    environment.systemPackages = [ cfg.package ];
    systemd.packages = [ cfg.package ];

    systemd.services.lactd = {
      description = "LACT GPU Control Daemon";
      # Restart when the config file changes.
      restartTriggers = lib.mkIf (cfg.settings != { }) [ configFile ];
      wantedBy = [ "multi-user.target" ];
    };
  };

  meta.maintainers = [ lib.maintainers.johnrtitor ];
}

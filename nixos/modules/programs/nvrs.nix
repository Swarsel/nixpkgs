{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.nvrs;
  settingsFormat = pkgs.formats.toml { };
in
{
  options.programs.nvrs = {
    enable = lib.mkEnableOption "nvrs";
    package = lib.mkPackageOption pkgs "nvrs" { };

    settings = lib.mkOption {
      default = { };

      description = ''
        Configuration written to {file}`$XDG_CONFIG_HOME/nvrs/config.toml`

        See <https://nvrs.adamperkowski.dev/configuration.html> for details.
      '';

      type = lib.types.submodule {
        freeformType = settingsFormat.type;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    environment.etc = {
      "nvrs/nvrs.toml" = lib.mkIf (cfg.settings != { }) {
        source = settingsFormat.generate "nvrs-config.toml" cfg.settings;
      };
    };

    environment.systemPackages = [ cfg.package ];
  };

  meta.maintainers = with lib.maintainers; [ koi ];
}

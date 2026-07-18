{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.libeufin;
  settingsFormat = pkgs.formats.ini { };
  configFile = settingsFormat.generate "generated-libeufin.conf" cfg.settings;
in

{
  options.services.libeufin = {
    settings = lib.mkOption {
      default = { };
      description = "Global configuration options for the libeufin bank system config file.";
      type = lib.types.submodule { freeformType = settingsFormat.type; };
    };
  };

  config = lib.mkIf (cfg.bank.enable || cfg.nexus.enable) {
    environment.etc."libeufin/libeufin.conf".source = configFile;
  };
}

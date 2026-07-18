{
  lib,
  config,
  modulesPath,
  pkgs,
  ...
}:
let
  settingsFormat = pkgs.formats.toml { };
in
{
  config.configFile = lib.mkOptionDefault (settingsFormat.generate "treefmt.toml" config.settings);

  options.settings = lib.mkOption {
    default = { };

    description = ''
      Settings used to build a treefmt config file.
    '';

    type = lib.types.submoduleWith {
      modules = [
        { freeformType = settingsFormat.type; }
      ];

      specialArgs = { inherit modulesPath; };
    };
  };
}

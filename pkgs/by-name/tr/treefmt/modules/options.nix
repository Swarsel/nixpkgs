{ lib, config, ... }:
{
  options = {
    configFile = lib.mkOption {
      # Ensure file is copied to the store
      apply = file: if lib.isDerivation file then file else "${file}";
      defaultText = lib.literalMD "generated from [](#opt-treefmt-settings)";

      description = ''
        The treefmt config file.
      '';

      type = lib.types.path;
    };

    name = lib.mkOption {
      default = lib.getName config.package + "-with-config";
      defaultText = lib.literalExpression "\"\${getName package}-with-config\"";

      description = ''
        Name to use for the wrapped treefmt package.
      '';

      type = lib.types.str;
    };

    package = lib.mkOption {
      defaultText = lib.literalExpression "pkgs.treefmt";

      description = ''
        The treefmt package to wrap.
      '';

      internal = true;
      type = lib.types.package;
    };

    runtimeInputs = lib.mkOption {
      default = [ ];

      description = ''
        Packages to include on treefmt's PATH.
      '';

      type = with lib.types; listOf package;
    };
  };
}

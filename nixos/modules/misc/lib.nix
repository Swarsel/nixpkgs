{ lib, ... }:

{
  options = {
    lib = lib.mkOption {
      default = { };

      description = ''
        This option allows modules to define helper functions, constants, etc.
      '';

      type = lib.types.attrsOf lib.types.attrs;
    };
  };
}

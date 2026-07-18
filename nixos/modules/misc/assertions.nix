{ lib, ... }:
{

  options = {

    assertions = lib.mkOption {
      default = [ ];

      description = ''
        This option allows modules to express conditions that must
        hold for the evaluation of the system configuration to
        succeed, along with associated error messages for the user.
      '';

      example = [
        {
          assertion = false;
          message = "you can't enable this for that reason";
        }
      ];

      internal = true;
      type = lib.types.listOf lib.types.unspecified;
    };

    warnings = lib.mkOption {
      default = [ ];

      description = ''
        This option allows modules to show warnings to users during
        the evaluation of the system configuration.
      '';

      example = [ "The `foo' service is deprecated and will go away soon!" ];
      internal = true;
      type = lib.types.listOf lib.types.str;
    };

  };
  # impl of assertions is in
  # - <nixpkgs/nixos/modules/system/activation/top-level.nix>
  # - <nixpkgs/lib/services/lib.nix>
}

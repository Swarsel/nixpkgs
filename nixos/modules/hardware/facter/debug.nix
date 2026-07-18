{
  config,
  lib,
  pkgs,
  extendModules,
  ...
}:
{

  options = {

    hardware.facter.debug = {
      nix-diff = lib.mkOption {
        description = ''
          A shell application which will produce a nix-diff of the system closure with and without facter enabled.
        '';

        type = lib.types.package;
      };

      nvd = lib.mkOption {
        description = ''
          A shell application which will produce an nvd diff of the system closure with and without facter enabled.
        '';

        type = lib.types.package;
      };
    };

    system.build = {
      noFacter = lib.mkOption {
        description = "A version of the system closure with facter disabled";
        type = lib.types.unspecified;
      };
    };

  };

  config.hardware.facter.debug = {

    nix-diff = pkgs.writeShellApplication {
      name = "facter-nix-diff";

      runtimeInputs = [
        config.nix.package
        pkgs.nix-diff
      ];

      text = ''
        nix-diff \
          ${config.system.build.noFacter.config.system.build.toplevel} \
          ${config.system.build.toplevel} \
          "$@"
      '';
    };

    nvd = pkgs.writeShellApplication {
      name = "facter-nvd-diff";

      runtimeInputs = [
        config.nix.package
        pkgs.nvd
      ];

      text = ''
        nvd diff \
          ${config.system.build.noFacter.config.system.build.toplevel} \
          ${config.system.build.toplevel} \
          "$@"
      '';
    };

  };

  config.system.build = {
    noFacter = extendModules {
      modules = [
        {
          # we 'disable' facter by overriding the report and setting it to empty with one caveat: hostPlatform
          config.hardware.facter.report = lib.mkForce {
            system = config.nixpkgs.hostPlatform;
          };
        }
      ];
    };
  };

}

{
  lib,
  config,
  options,
  pkgs,
  ...
}:
{
  config.result = pkgs.symlinkJoin (finalAttrs: {
    inherit (config.package) meta version;
    pname = config.name;
    nativeBuildInputs = [ pkgs.makeBinaryWrapper ];

    env = {
      inherit (config) configFile;
      binPath = lib.makeBinPath config.runtimeInputs;
    };

    postBuild = ''
      wrapProgram "$out/bin/treefmt" \
        --prefix PATH : "$binPath" \
        --add-flags "--config-file $configFile"
    '';

    paths = [ config.package ];

    passthru = {
      inherit (config) runtimeInputs;
      inherit config options;

      check = pkgs.callPackage ../check-wrapper.nix {
        wrapper = finalAttrs.finalPackage;
      };
    };
  });

  options.result = lib.mkOption {
    description = ''
      The wrapped treefmt package.
    '';

    internal = true;
    readOnly = true;
    type = lib.types.package;
  };
}

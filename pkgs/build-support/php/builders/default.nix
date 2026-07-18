{ callPackage, callPackages, ... }:
{
  v1 = {
    buildComposerProject = callPackage ./v1/build-composer-project.nix { };
    buildComposerWithPlugin = callPackage ./v1/build-composer-with-plugin.nix { };
    composerHooks = callPackages ./v1/hooks { };
    mkComposerRepository = callPackage ./v1/build-composer-repository.nix { };
  };

  v2 = {
    buildComposerProject = callPackage ./v2/build-composer-project.nix { };
    composerHooks = callPackages ./v2/hooks { };
    mkComposerVendor = callPackage ./v2/build-composer-vendor.nix { };
  };
}

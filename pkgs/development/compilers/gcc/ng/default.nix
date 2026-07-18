{
  lib,
  stdenv,
  binutils,
  binutilsNoLibc,
  buildPackages,
  callPackage,
  generateSplicesForMkScope,
  stdenvAdapters,
  targetPackages,
  gccVersions ? { },
  patchesFn ? lib.id,
  ...
}@packageSetArgs:
let
  versions = {
    "15.2.0".officialRelease.sha256 = "sha256-Q4/ZloJrDIJIWinaA6ctcdbjVBqD7HAt9Ccfb+Al0k4=";
  }
  // gccVersions;

  mkPackage =
    {
      gitRelease ? null,
      monorepoSrc ? null,
      name ? null,
      officialRelease ? null,
      version ? null,
    }@args:
    let
      inherit
        (import ./common/common-let.nix {
          inherit
            lib
            gitRelease
            officialRelease
            version
            ;
        })
        releaseInfo
        ;
      inherit (releaseInfo) release_version;
      attrName =
        args.name or (if (gitRelease != null) then "git" else lib.versions.major release_version);
    in
    lib.nameValuePair attrName (
      lib.recurseIntoAttrs (
        callPackage ./common (
          {
            inherit (stdenvAdapters) overrideCC;

            inherit
              officialRelease
              gitRelease
              monorepoSrc
              version
              patchesFn
              ;

            buildGccPackages = buildPackages."gccNGPackages_${attrName}";
            otherSplices = generateSplicesForMkScope "gccNGPackages_${attrName}";
            targetGccPackages = targetPackages."gccNGPackages_${attrName}" or gccPackages."${attrName}";
          }
          // packageSetArgs # Allow overrides.
        )
      )
    );

  gccPackages = lib.mapAttrs' (version: args: mkPackage (args // { inherit version; })) versions;
in
gccPackages // { inherit mkPackage; }

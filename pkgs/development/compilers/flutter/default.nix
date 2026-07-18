{
  lib,
  stdenv,
  fetchFromGitHub,
  callPackage,
  dart,
  dart-bin,
  fetchzip,
  runCommand,
  useNixpkgsEngine ? false,
}:
let
  mkCustomFlutter = args: callPackage ./flutter.nix args;
  wrapFlutter = flutter: callPackage ./wrapper.nix { inherit flutter; };
  getPatches =
    dir:
    let
      files = builtins.attrNames (builtins.readDir dir);
    in
    if (builtins.pathExists dir) then map (f: dir + ("/" + f)) files else [ ];
  mkFlutter =
    {
      artifactHashes,
      channel,
      dartHash,
      dartVersion,
      engineHashes,
      enginePatches,
      engineSwiftShaderHash,
      engineSwiftShaderRev,
      engineVersion,
      flutterHash,
      patches,
      pubspecLock,
      version,
    }:
    let
      args = {
        inherit
          version
          engineVersion
          engineSwiftShaderRev
          engineSwiftShaderHash
          engineHashes
          enginePatches
          patches
          pubspecLock
          artifactHashes
          useNixpkgsEngine
          channel
          ;

        src =
          let
            source = fetchFromGitHub {
              hash = flutterHash;
              owner = "flutter";
              repo = "flutter";
              tag = version;
            };
          in
          (
            if lib.versionAtLeast version "3.32" then
              # # Could not determine engine revision
              (runCommand source.name { } ''
                cp --recursive ${source} $out
                chmod +w $out/bin
                mkdir $out/bin/cache
                cp $out/bin/internal/engine.version $out/bin/cache/engine.stamp
                touch $out/bin/cache/engine.realm
              '')
            else
              source
          );

        dart =
          let
            hash =
              dartHash.${stdenv.hostPlatform.system}
                or (throw "Unsupported system: ${stdenv.hostPlatform.system}");
          in
          (
            if lib.versionAtLeast version "3.41" then
              (dart-bin.overrideAttrs (oldAttrs: {
                version = dartVersion;

                src = oldAttrs.src.overrideAttrs (_: {
                  inherit hash;
                });
              }))
            else
              (dart-bin.overrideAttrs (_: {
                # This overrideAttrs is used to replace the version in src.url
                version = dartVersion;
                __intentionallyOverridingVersion = true;
              })).overrideAttrs
                (oldAttrs: {
                  src = fetchzip {
                    inherit (oldAttrs.src) url;
                    inherit hash;
                  };
                })
          );
      };
    in
    (mkCustomFlutter args).overrideAttrs (
      prev: next: {
        passthru = next.passthru // {
          inherit wrapFlutter mkCustomFlutter mkFlutter;

          buildFlutterApplication = callPackage ./build-support/build-flutter-application.nix {
            flutter = wrapFlutter (mkCustomFlutter args);
          };
        };
      }
    );

  flutterVersions = lib.mapAttrs' (
    version: _:
    let
      versionDir = ./versions + "/${version}";
      data = lib.importJSON (versionDir + "/data.json");
    in
    lib.nameValuePair "v${version}" (
      wrapFlutter (
        mkFlutter (
          {
            patches = (getPatches ./patches) ++ (getPatches (versionDir + "/patches"));
            enginePatches = (getPatches ./engine/patches) ++ (getPatches (versionDir + "/engine/patches"));
          }
          // data
        )
      )
    )
  ) (builtins.readDir ./versions);

  stableFlutterVersions = lib.attrsets.filterAttrs (_: v: v.channel == "stable") flutterVersions;
  betaFlutterVersions = lib.attrsets.filterAttrs (_: v: v.channel == "beta") flutterVersions;
in
flutterVersions
// {
  inherit wrapFlutter mkFlutter;
}
// lib.optionalAttrs (betaFlutterVersions != { }) {
  beta = flutterVersions.${lib.last (lib.naturalSort (builtins.attrNames betaFlutterVersions))};
}
// lib.optionalAttrs (stableFlutterVersions != { }) {
  stable = flutterVersions.${lib.last (lib.naturalSort (builtins.attrNames stableFlutterVersions))};
}

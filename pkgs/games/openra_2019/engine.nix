/*
  The package definition for an OpenRA engine.
   It shares code with `mod.nix` by what is defined in `common.nix`.
   Similar to `mod.nix` it is a generic package definition,
   in order to make it easy to define multiple variants of the OpenRA engine.
   For each mod provided by the engine, a wrapper script is created,
   matching the naming convention used by `mod.nix`.
   This package could be seen as providing a set of in-tree mods,
   while the `mod.nix` packages provide a single out-of-tree mod.
*/
{
  lib,
  stdenv,
  engine,
  packageAttrs,
  patchEngine,
  wrapLaunchGame,
}:

let
  version = "${engine.name}-${engine.version}";
in
stdenv.mkDerivation (
  {
    inherit version;
    pname = "openra_2019";
    src = engine.src;
    postPatch = patchEngine "." version;

    buildFlags = [
      "DEBUG=false"
      "default"
      "man-page"
    ];

    postInstall = ''
      ${wrapLaunchGame "" "openra"}

      ${lib.concatStrings (
        map (mod: ''
          makeWrapper $out/bin/openra $out/bin/openra-${mod} --add-flags Game.Mod=${mod}
        '') engine.mods
      )}
    '';

    checkTarget = "nunit test";

    configurePhase = ''
      runHook preConfigure

      make version VERSION=${lib.escapeShellArg version}

      runHook postConfigure
    '';

    installTargets = [
      "install"
      "install-linux-icons"
      "install-linux-desktop"
      "install-linux-appdata"
      "install-linux-mime"
      "install-man-page"
    ];

    meta = packageAttrs.meta // engine.meta;
  }
  // removeAttrs packageAttrs [ "meta" ]
)

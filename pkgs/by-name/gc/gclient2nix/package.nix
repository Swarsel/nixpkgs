{
  lib,
  fetchFromGitHub,
  buildPackages,
  callPackage,
  fetchFromGitiles,
  fetchgit,
  makeWrapper,
  nurl,
  python3,
  runCommand,
  writers,
}:

let
  fetchers = {
    inherit fetchgit fetchFromGitiles fetchFromGitHub;
  };

  importGclientDeps =
    depsAttrsOrFile:
    let
      depsAttrs = if lib.isAttrs depsAttrsOrFile then depsAttrsOrFile else lib.importJSON depsAttrsOrFile;
      fetchdep = dep: fetchers.${dep.fetcher} dep.args;
      fetchedDeps = lib.mapAttrs (_name: fetchdep) depsAttrs;
      manifestContents = lib.mapAttrs (_: dep: {
        path = dep;
      }) fetchedDeps;
      manifest = writers.writeJSON "gclient-manifest.json" manifestContents;
    in
    manifestContents
    // {
      inherit manifest;
      __toString = _: manifest;
    };

  gclientUnpackHook = callPackage (
    {
      lib,
      jq,
      makeSetupHook,
    }:

    makeSetupHook {
      name = "gclient-unpack-hook";

      substitutions = {
        jq = lib.getExe buildPackages.jq;
      };

      meta.license = lib.licenses.mit;
    } ./gclient-unpack-hook.sh
  ) { };

  python = python3.withPackages (
    ps: with ps; [
      joblib
      platformdirs
      click
      click-log
    ]
  );

in

runCommand "gclient2nix"
  {
    nativeBuildInputs = [ makeWrapper ];
    buildInputs = [ python ];

    # substitutions
    depot_tools_checkout = fetchgit {
      hash = "sha256-OCIay+a+DHvKKIbDMSjTf6CbHHVfp8k0n1AO3E4yx1U=";
      rev = "977d597d75def6781f890cdce459969a9568ea07";
      url = "https://chromium.googlesource.com/chromium/tools/depot_tools";
    };

    passthru = {
      inherit fetchers importGclientDeps gclientUnpackHook;
    };
  }
  ''
    mkdir -p $out/bin
    substituteAll ${./gclient2nix.py} $out/bin/gclient2nix
    chmod u+x $out/bin/gclient2nix
    patchShebangs $out/bin/gclient2nix
    wrapProgram $out/bin/gclient2nix --set PATH "${lib.makeBinPath [ nurl ]}"
  ''

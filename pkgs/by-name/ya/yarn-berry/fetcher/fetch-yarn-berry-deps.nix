{
  lib,
  stdenv,
  berryVersion,
  cacert,
  nix-prefetch-git,
  yarn-berry-fetcher,
}:

{
  hash ? "",
  sha256 ? "",
  src ? null,
  ...
}@args:

let
  hash_ =
    if hash != "" then
      {
        outputHash = hash;
        outputHashAlgo = null;
      }
    else if sha256 != "" then
      {
        outputHash = sha256;
        outputHashAlgo = "sha256";
      }
    else
      {
        outputHash = lib.fakeSha256;
        outputHashAlgo = "sha256";
      };
in

stdenv.mkDerivation (
  {
    nativeBuildInputs = [
      yarn-berry-fetcher
      nix-prefetch-git
      cacert
    ];

    buildPhase = ''
      runHook preBuild

      yarnLock=''${yarnLock:=$PWD/yarn.lock}
      yarn-berry-fetcher fetch $yarnLock $missingHashes

      runHook postBuild
    '';

    dontFixup = true; # fixup phase does the patching of the shebangs, and FODs must never contain nix store paths.
    dontInstall = true;
    dontUnpack = src == null;
    impureEnvVars = lib.fetchers.proxyImpureEnvVars;
    # The name is fixed as to not produce multiple store paths with the same content
    name = "offline";
    outputHashMode = "recursive";

    passthru = {
      inherit berryVersion;
    };
  }
  // hash_
  // (removeAttrs args (
    [
      "name"
      "pname"
      "version"
      "hash"
      "sha256"
    ]
    ++ (lib.optional (src == null) "src")
  ))
)

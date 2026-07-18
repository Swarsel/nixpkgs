# See also ./make-hadrian.nix
{
  lib,
  Cabal,
  base,
  base16-bytestring,
  # GHC we are using to bootstrap hadrian (stage0)
  bootGhcVersion,
  bytestring,
  containers,
  cryptohash-sha256,
  directory,
  extra,
  filepath,
  # GHC source tree to build hadrian from
  ghcSrc,
  ghcVersion,
  mkDerivation,
  mtl,
  parsec,
  shake,
  text,
  transformers,
  unordered-containers,
  writeText,
  # Dependencies that are not on Hackage and only used in certain Hadrian versions
  ghc-platform ? null,
  ghc-toolchain ? null,
  # Customization
  userSettings ? null,
}:

mkDerivation {
  pname = "hadrian";
  version = ghcVersion;
  src = ghcSrc;

  # Overwrite UserSettings.hs with a provided custom one
  postPatch = lib.optionalString (userSettings != null) ''
    install -m644 "${writeText "UserSettings.hs" userSettings}" src/UserSettings.hs
  '';

  configureFlags = [
    # avoid QuickCheck dep which needs shared libs / TH
    "-f-selftest"
    # Building hadrian with -O1 takes quite some time with little benefit.
    # Additionally we need to recompile it on every change of UserSettings.hs.
    # See https://gitlab.haskell.org/ghc/ghc/-/merge_requests/1190
    "-O0"
  ];

  description = "GHC build system";

  executableHaskellDepends = [
    base
    bytestring
    Cabal
    containers
    directory
    extra
    filepath
    mtl
    parsec
    shake
    text
    transformers
    unordered-containers
  ]
  ++ lib.optionals (lib.versionAtLeast ghcVersion "9.7") [
    cryptohash-sha256
    base16-bytestring
  ]
  ++ lib.optionals (lib.versionAtLeast ghcVersion "9.9") [
    ghc-platform
    ghc-toolchain
  ];

  isExecutable = true;
  isLibrary = false;

  jailbreak =
    # Ignore bound directory >= 1.3.9.0, unless the bootstrapping GHC ships it
    # which is the case for >= 9.12. Upstream uses this to avoid a race condition
    # that only seems to affect Windows. We never build GHC natively on Windows.
    # See also https://gitlab.haskell.org/ghc/ghc/-/issues/24382,
    # https://gitlab.haskell.org/ghc/ghc/-/commit/a2c033cf826,
    # https://gitlab.haskell.org/ghc/ghc/-/commit/7890f2d8526…
    (
      lib.versionOlder bootGhcVersion "9.12"
      && (
        (lib.versionAtLeast ghcVersion "9.6.7" && lib.versionOlder ghcVersion "9.7")
        || lib.versionAtLeast ghcVersion "9.11"
      )
    );

  license = lib.licenses.bsd3;

  postUnpack = ''
    sourceRoot="$sourceRoot/hadrian"
  '';

  passthru = {
    # Expose »private« dependencies if any
    inherit ghc-platform ghc-toolchain;
  };
}

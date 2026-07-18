{
  lib,
  stdenv,
  Foundation,
  XCTest,
  callPackage,
  clang,
  fetchpatch,
  ncurses,
  replaceVars,
  sqlite,
  swift,
  swiftpm,
  swiftpm2nix,
}:
let
  sources = callPackage ../sources.nix { };
  generated = swiftpm2nix.helpers ./generated;

  # On Darwin, we only want ncurses in the linker search path, because headers
  # are part of libsystem. Adding its headers to the search path causes strange
  # mixing and errors.
  # TODO: Find a better way to prevent this conflict.
  ncursesInput = if stdenv.hostPlatform.isDarwin then ncurses.out else ncurses;
in
stdenv.mkDerivation {
  inherit (sources) version;
  pname = "swift-driver";
  src = sources.swift-driver;

  patches = [
    ./patches/disable-catalyst.patch
    (replaceVars ./patches/linux-fix-linking.patch {
      inherit clang;
    })
    # TODO: Replace with branch patch once merged:
    # https://github.com/apple/swift-driver/pull/1197
    (fetchpatch {
      hash = "sha256-eVBaKN6uzj48ZnHtwGV0k5ChKjak1tDCyE+wTdyGq2c=";
      url = "https://github.com/apple/swift-driver/commit/d3ef9cdf4871a58eddec7ff0e28fe611130da3f9.patch";
    })
    # Prevent a warning about SDK directories we don't have.
    (replaceVars ./patches/prevent-sdk-dirs-warnings.patch {
      inherit (builtins) storeDir;
    })
  ];

  nativeBuildInputs = [
    swift
    swiftpm
  ];

  buildInputs = [
    Foundation
    XCTest
    sqlite
    ncursesInput
  ];

  # TODO: Tests depend on indexstore-db being provided by an existing Swift
  # toolchain. (ie. looks for `../lib/libIndexStore.so` relative to swiftc.
  #doCheck = true;
  # TODO: Darwin-specific installation includes more, but not sure why.
  installPhase = ''
    binPath="$(swiftpmBinPath)"
    mkdir -p $out/bin
    for executable in swift-driver swift-help swift-build-sdk-interfaces; do
      cp $binPath/$executable $out/bin/
    done
  '';

  configurePhase = generated.configure;

  meta = {
    description = "Swift compiler driver";
    homepage = "https://github.com/apple/swift-driver";
    license = lib.licenses.asl20;
    platforms = with lib.platforms; linux ++ darwin;
    teams = [ lib.teams.swift ];
  };
}

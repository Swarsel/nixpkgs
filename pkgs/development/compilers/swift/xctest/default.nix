{
  lib,
  stdenv,
  DarwinTools,
  Foundation,
  callPackage,
  cmake,
  ninja,
  swift,
}:

let
  sources = callPackage ../sources.nix { };
in
stdenv.mkDerivation {
  inherit (sources) version;
  pname = "swift-corelibs-xctest";
  src = sources.swift-corelibs-xctest;
  outputs = [ "out" ];

  postPatch = lib.optionalString stdenv.hostPlatform.isDarwin ''
    # On Darwin only, Swift uses arm64 as cpu arch.
    substituteInPlace cmake/modules/SwiftSupport.cmake \
      --replace-fail '"aarch64" PARENT_SCOPE' '"arm64" PARENT_SCOPE'
  '';

  nativeBuildInputs = [
    cmake
    ninja
    swift
  ]
  ++ lib.optional stdenv.hostPlatform.isDarwin DarwinTools; # sw_vers

  buildInputs = [ Foundation ];
  cmakeFlags = lib.optional stdenv.hostPlatform.isDarwin "-DUSE_FOUNDATION_FRAMEWORK=ON";

  preConfigure = ''
    # On aarch64-darwin, our minimum target is 11.0, but we can target lower,
    # and some dependants require a lower target. Harmless on non-Darwin.
    export MACOSX_DEPLOYMENT_TARGET=10.12
  '';

  postInstall = lib.optionalString stdenv.hostPlatform.isDarwin ''
    # Darwin normally uses the Xcode version of XCTest. Installing
    # swift-corelibs-xctest is probably not officially supported, but we have
    # no alternative. Fix up the installation here.
    mv $out/lib/swift/darwin/${swift.swiftArch}/* $out/lib/swift/darwin
    rmdir $out/lib/swift/darwin/${swift.swiftArch}
    mv $out/lib/swift/darwin $out/lib/swift/${swift.swiftOs}
  '';

  meta = {
    description = "Framework for writing unit tests in Swift";
    homepage = "https://github.com/apple/swift-corelibs-xctest";
    license = lib.licenses.asl20;
    platforms = lib.platforms.all;
    teams = [ lib.teams.swift ];
  };
}

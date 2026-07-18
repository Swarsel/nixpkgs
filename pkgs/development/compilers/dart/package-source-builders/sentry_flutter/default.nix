{
  lib,
  stdenv,
  fetchFromGitHub,
}:

{ src, version, ... }:

let
  sentry-native = fetchFromGitHub {
    fetchSubmodules = true;
    hash = "sha256-1jyJGiIrX0TsRDzAeg3IuE1Vf5STAaG8JVxdbmPMXGQ=";
    owner = "getsentry";
    repo = "sentry-native";
    tag = "0.9.1";
  };
in
stdenv.mkDerivation (finalAttrs: {
  inherit version src;
  inherit (src) passthru;
  pname = "sentry_flutter";

  postPatch = lib.optionalString (lib.versionAtLeast version "8.10.0") ''
    sed -i "s|GIT_REPOSITORY.*|SOURCE_DIR "${sentry-native}"|" sentry-native/sentry-native.cmake
    sed -i '/GIT_TAG/d' sentry-native/sentry-native.cmake
  '';

  installPhase = ''
    runHook preInstall

    cp -r . $out

    runHook postInstall
  '';
})

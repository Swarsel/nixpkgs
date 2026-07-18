{
  lib,
  stdenv,
}:

{ src, version, ... }:

stdenv.mkDerivation {
  inherit version src;
  inherit (src) passthru;
  pname = "volume_controller";

  postPatch = lib.optionalString (lib.versionAtLeast version "3.4.0") ''
    substituteInPlace linux/CMakeLists.txt \
      --replace-fail "# ALSA dependency for volume control" "find_package(PkgConfig REQUIRED)" \
      --replace-fail "find_package(ALSA REQUIRED)" "pkg_check_modules(ALSA REQUIRED alsa)"
  '';

  installPhase = ''
    runHook preInstall

    cp -r . $out

    runHook postInstall
  '';
}

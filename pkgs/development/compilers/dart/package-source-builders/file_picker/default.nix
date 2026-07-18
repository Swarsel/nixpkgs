{
  lib,
  stdenv,
  zenity,
}:

{ src, version, ... }:

stdenv.mkDerivation {
  inherit version src;
  inherit (src) passthru;
  pname = "file_picker";

  postPatch = lib.optionalString (lib.versionOlder version "10.3.0") ''
    substituteInPlace lib/src/linux/file_picker_linux.dart \
        --replace-fail "isExecutableOnPath('zenity')" "'${lib.getExe zenity}'"
  '';

  installPhase = ''
    runHook preInstall

    cp -r . $out

    runHook postInstall
  '';
}

{
  lib,
  stdenv,
  pdfium-binaries,
}:

{ src, version, ... }:

stdenv.mkDerivation {
  inherit version src;
  inherit (src) passthru;
  pname = "pdfium_dart";

  postPatch = lib.optionalString (lib.versionAtLeast version "0.2.0") ''
    substitute ${./build.dart} hook/build.dart \
      --replace-fail "@pdfium-binaries@" "${pdfium-binaries}"
  '';

  installPhase = ''
    runHook preInstall

    cp --recursive . $out

    runHook postInstall
  '';
}

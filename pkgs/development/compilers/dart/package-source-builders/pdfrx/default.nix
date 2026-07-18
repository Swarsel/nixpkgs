{
  lib,
  stdenv,
  pdfium-binaries,
}:

{ src, version, ... }:

stdenv.mkDerivation {
  inherit version src;
  inherit (src) passthru;
  pname = "pdfrx";

  postPatch = lib.optionalString (lib.versionOlder version "2.2.9") ''
    substituteInPlace linux/CMakeLists.txt \
      --replace-fail "\''${PDFIUM_DIR}/\''${PDFIUM_RELEASE}" "${pdfium-binaries}"
  '';

  installPhase = ''
    runHook preInstall

    cp --recursive . $out

    runHook postInstall
  '';
}

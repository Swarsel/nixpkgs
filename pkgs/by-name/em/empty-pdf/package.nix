{
  lib,
  imagemagick,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation {
  strictDeps = true;
  nativeBuildInputs = [ imagemagick ];

  buildPhase = ''
    runHook preBuild

    magick xc:none -page Letter empty.pdf

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mv empty.pdf $out

    runHook postInstall
  '';

  __structuredAttrs = true;
  dontUnpack = true;
  name = "empty-pdf";

  meta = {
    description = "Empty PDF file intended for testing";

    maintainers = with lib.maintainers; [
      pandapip1
      thefossguy
    ];

    platforms = imagemagick.meta.platforms;
  };
}

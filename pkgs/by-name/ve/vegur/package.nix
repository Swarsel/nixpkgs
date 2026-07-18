{
  lib,
  fetchzip,
  installFonts,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "vegur";
  version = "${finalAttrs.majorVersion}.${finalAttrs.minorVersion}";

  src = fetchzip {
    url = "https://dotcolon.net/files/fonts/vegur_${finalAttrs.majorVersion}${finalAttrs.minorVersion}.zip";
    hash = "sha256-sGb3mEb3g15ZiVCxEfAanly8zMUopLOOjw8W4qbXLPA=";
    stripRoot = false;
  };

  nativeBuildInputs = [ installFonts ];
  majorVersion = "0";
  minorVersion = "701";

  meta = {
    description = "Humanist sans serif font";
    homepage = "https://dotcolon.net/fonts/vegur/";
    license = lib.licenses.cc0;

    maintainers = with lib.maintainers; [
      djacu
      minijackson
    ];

    platforms = lib.platforms.all;
  };
})

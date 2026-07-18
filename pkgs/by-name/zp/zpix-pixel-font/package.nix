{
  lib,
  fetchurl,
  stdenvNoCC,
}:
stdenvNoCC.mkDerivation rec {
  pname = "zpix-pixel-font";
  version = "3.1.8";

  installPhase = ''
    runHook preInstall
    install -Dm444 ''${srcs[0]} $out/share/fonts/misc/zpix.bdf
    install -Dm444 ''${srcs[1]} $out/share/fonts/truetype/zpix.ttf
    runHook postInstall
  '';

  __structuredAttrs = true;
  dontUnpack = true;

  srcs = [
    (fetchurl {
      hash = "sha256-qE6YPKuk1FRRrTvmy4YIDuxRfslma264piUDj1FWtk4=";
      name = "zpix-pixel-font.bdf";
      url = "https://github.com/SolidZORO/zpix-pixel-font/releases/download/v${version}/zpix.bdf";
    })
    (fetchurl {
      hash = "sha256-UIgLGsVTbyhYMKfTYiA+MZmV4dFT9HX3sxTdrcc4vE0=";
      name = "zpix-pixel-font.ttf";
      url = "https://github.com/SolidZORO/zpix-pixel-font/releases/download/v${version}/zpix.ttf";
    })
  ];

  meta = {
    description = "Pixel font supporting multiple languages like English, Chinese and Japanese";
    homepage = "https://github.com/SolidZORO/zpix-pixel-font/";
    changelog = "https://github.com/SolidZORO/zpix-pixel-font/blob/master/CHANGELOG.md";
    license = lib.licenses.unfree;
    maintainers = [ lib.maintainers.adriangl ];
    platforms = lib.platforms.all;
  };
}

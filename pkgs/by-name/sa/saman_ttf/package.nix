{
  lib,
  fetchurl,
  stdenvNoCC,
  unzip,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "saman_ttf";
  version = "1.001";

  src = fetchurl {
    url = "https://github.com/tcgumus/saman/releases/download/v${finalAttrs.version}/SamanDere-Regular.ttf";
    hash = "sha256-hLlo4qtxL1RDiA9PpRvo2F7rdCVGPs2G8NHKydLfJXU=";
  };

  installPhase = ''
    runHook preInstall
    install -Dm644 $src $out/share/fonts/truetype/SamanDere-Regular.ttf
    runHook postInstall
  '';

  dontUnpack = true;

  meta = {
    description = "Medium contrast sans serif font for web use";
    homepage = "https://github.com/tcgumus/saman";
    license = lib.licenses.ofl;
    maintainers = with lib.maintainers; [ gigahawk ];
    platforms = lib.platforms.all;
  };
})

{
  lib,
  fetchzip,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation rec {
  pname = "overpass";
  version = "3.0.5";

  src = fetchzip {
    url = "https://github.com/RedHatOfficial/Overpass/releases/download/v${version}/overpass-${version}.zip";
    hash = "sha256-8AWT0/DELfNWXtZOejC90DbUSOtyGt9tSkcSuO7HP2o=";
  };

  installPhase = ''
    runHook preInstall

    install -Dm644 */*/*.otf -t $out/share/fonts/opentype
    install -Dm644 */*/*.ttf -t $out/share/fonts/truetype
    install -Dm644 *.md  -t $out/share/doc/${pname}-${version}

    runHook postInstall
  '';

  meta = {
    description = "Font heavily inspired by Highway Gothic";
    homepage = "https://overpassfont.org/";
    license = lib.licenses.ofl;
    maintainers = [ lib.maintainers.rycee ];
    platforms = lib.platforms.all;
  };
}

{
  lib,
  fetchurl,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation rec {
  pname = "marathi-cursive";
  version = "2.1";

  src = fetchurl {
    url = "https://github.com/MihailJP/MarathiCursive/releases/download/v${version}/MarathiCursive-${version}.tar.xz";
    hash = "sha256-C/z8ALV9bht0SaYqACO5ulSVCk1d6wBwvpVC4ZLgtek=";
  };

  installPhase = ''
    runHook preInstall

    install -m444 -Dt $out/share/fonts/marathi-cursive *.otf *.ttf
    install -m444 -Dt $out/share/doc/${pname}-${version} README *.txt

    runHook postInstall
  '';

  meta = {
    description = "Modi script font with Graphite and OpenType support";
    homepage = "https://github.com/MihailJP/MarathiCursive";
    license = lib.licenses.mplus;
    maintainers = with lib.maintainers; [ mathnerd314 ];
    platforms = lib.platforms.all;
  };
}

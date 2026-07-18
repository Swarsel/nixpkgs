{
  lib,
  fetchzip,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "anonymous-pro-fonts";
  version = "1.002";

  src = fetchzip {
    url = "https://www.marksimonson.com/assets/content/fonts/AnonymousPro-${
      lib.replaceStrings [ "." ] [ "_" ] finalAttrs.version
    }.zip";

    hash = "sha256-FhyzV4By8XKN9EyukAknzml/7lUuV6Evnt6Ht3H6TUU=";
  };

  installPhase = ''
    runHook preInstall

    install -Dm644 *.ttf -t $out/share/fonts/truetype
    install -Dm644 *.txt -t $out/share/doc/AnonymousPro-${finalAttrs.version}

    runHook postInstall
  '';

  meta = {
    description = "TrueType font set intended for source code";

    longDescription = ''
      Anonymous Pro (2009) is a family of four fixed-width fonts
      designed with coding in mind. Anonymous Pro features an
      international, Unicode-based character set, with support for
      most Western and Central European Latin-based languages, plus
      Greek and Cyrillic. It is designed by Mark Simonson.
    '';

    homepage = "https://www.marksimonson.com/fonts/view/anonymous-pro";
    license = lib.licenses.ofl;
    maintainers = with lib.maintainers; [ raskin ];
    platforms = lib.platforms.all;
  };
})

{
  lib,
  fetchzip,
  installFonts,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation rec {
  pname = "stix-two";
  version = "2.13";

  src = fetchzip {
    url = "https://github.com/stipub/stixfonts/raw/v${version}/zipfiles/STIX${
      builtins.replaceStrings [ "." ] [ "_" ] version
    }-all.zip";

    hash = "sha256-hfQmrw7HjlhQSA0rVTs84i3j3iMVR0k7tCRBcB6hEpU=";
    stripRoot = false;
  };

  outputs = [
    "out"
    "webfont"
  ];

  nativeBuildInputs = [ installFonts ];
  preInstall = "rm -r static_ttf_woff2/";

  meta = {
    description = "Fonts for Scientific and Technical Information eXchange";
    homepage = "https://www.stixfonts.org/";
    license = lib.licenses.ofl;
    maintainers = [ lib.maintainers.rycee ];
    platforms = lib.platforms.all;
  };
}

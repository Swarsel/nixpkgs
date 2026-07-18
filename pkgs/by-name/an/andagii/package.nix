{
  lib,
  fetchzip,
  installFonts,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation {
  pname = "andagii";
  version = "1.0.2";

  src = fetchzip {
    url = "http://www.i18nguy.com/unicode/andagii.zip";
    hash = "sha256-U7wC55G8jIvMMyPcEiJQ700A7nkWdgWK1LM0F/wgDCg=";
    curlOpts = "--user-agent 'Mozilla/5.0'";
  };

  nativeBuildInputs = [ installFonts ];

  meta = {
    description = "Unicode Plane 1 Osmanya script font";
    homepage = "http://www.i18nguy.com/unicode/unicode-font.html";
    license = lib.licenses.unfreeRedistributable; # upstream uses the term copyleft only
    maintainers = [ lib.maintainers.raskin ];
    platforms = lib.platforms.all;
  };
}

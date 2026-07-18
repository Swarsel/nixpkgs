{
  lib,
  fetchFromGitHub,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation rec {
  pname = "parastoo-fonts";
  version = "2.0.1";

  src = fetchFromGitHub {
    owner = "rastikerdar";
    repo = "parastoo-font";
    rev = "v${version}";
    hash = "sha256-E94B9R2h227D49dscCBsprmb7w0GrQ+2tWOWRf8FH30=";
  };

  installPhase = ''
    runHook preInstall

    find . -name '*.ttf' -exec install -m444 -Dt $out/share/fonts/parastoo-fonts {} \;

    runHook postInstall
  '';

  meta = {
    description = "Persian (Farsi) Font - فونت ( قلم ) فارسی پرستو";
    homepage = "https://github.com/rastikerdar/parastoo-font";
    license = lib.licenses.ofl;
    maintainers = [ ];
    platforms = lib.platforms.all;
  };
}

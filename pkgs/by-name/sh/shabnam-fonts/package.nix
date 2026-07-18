{
  lib,
  fetchFromGitHub,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation rec {
  pname = "shabnam-fonts";
  version = "5.0.1";

  src = fetchFromGitHub {
    owner = "rastikerdar";
    repo = "shabnam-font";
    rev = "v${version}";
    hash = "sha256-H03GTKRVPiwU4edkr4x5upW4JCy6320Lo+cKK9FRMQs=";
  };

  installPhase = ''
    runHook preInstall

    find . -name '*.ttf' -exec install -m444 -Dt $out/share/fonts/shabnam-fonts {} \;

    runHook postInstall
  '';

  meta = {
    description = "Persian (Farsi) Font - فونت (قلم) فارسی شبنم";
    homepage = "https://github.com/rastikerdar/shabnam-font";
    license = lib.licenses.ofl;
    maintainers = [ ];
    platforms = lib.platforms.all;
  };
}

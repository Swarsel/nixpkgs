{
  lib,
  fetchFromGitHub,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation rec {
  pname = "nahid-fonts";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "rastikerdar";
    repo = "nahid-font";
    rev = "v${version}";
    hash = "sha256-r8/W0/pJV6OX954spIITvW7M6lIbZRpbsvEHErnXglg=";
  };

  installPhase = ''
    runHook preInstall

    find . -name '*.ttf' -exec install -m444 -Dt $out/share/fonts/nahid-fonts {} \;

    runHook postInstall
  '';

  meta = {
    description = "Persian (Farsi) Font - قلم (فونت) فارسی ناهید";
    homepage = "https://github.com/rastikerdar/nahid-font";
    license = lib.licenses.free;
    maintainers = [ ];
    platforms = lib.platforms.all;
  };
}

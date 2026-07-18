{
  lib,
  fetchFromGitHub,
  installFonts,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "sahel-fonts";
  version = "3.4.0";

  src = fetchFromGitHub {
    owner = "rastikerdar";
    repo = "sahel-font";
    tag = "v${finalAttrs.version}";
    hash = "sha256-U4tIICXZFK9pk7zdzRwBPIPYFUlYXPSebnItUJUgGJY=";
  };

  outputs = [
    "out"
    "webfont"
  ];

  nativeBuildInputs = [ installFonts ];

  meta = {
    description = "Persian (farsi) Font - فونت (قلم) فارسی ساحل";
    homepage = "https://github.com/rastikerdar/sahel-font";
    license = lib.licenses.ofl;
    maintainers = with lib.maintainers; [ pancaek ];
    platforms = lib.platforms.all;
  };
})

{
  lib,
  fetchFromGitHub,
  installFonts,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "samim-fonts";
  version = "4.0.5";

  src = fetchFromGitHub {
    owner = "rastikerdar";
    repo = "samim-font";
    tag = "v${finalAttrs.version}";
    hash = "sha256-DVBMsNOVAVwzlZ3cDus/3CSsC05bLZalQ2KeueEvwXs=";
  };

  outputs = [
    "out"
    "webfont"
  ];

  nativeBuildInputs = [ installFonts ];

  meta = {
    description = "Persian (Farsi) Font - فونت (قلم) فارسی صمیم";
    homepage = "https://github.com/rastikerdar/samim-font";
    license = lib.licenses.ofl;
    maintainers = with lib.maintainers; [ pancaek ];
    platforms = lib.platforms.all;
  };
})

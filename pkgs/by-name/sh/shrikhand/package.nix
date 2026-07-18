{
  lib,
  fetchFromGitHub,
  installFonts,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation {
  pname = "shrikhand";
  version = "unstable-2016-03-03";

  src = fetchFromGitHub {
    owner = "jonpinhorn";
    repo = "shrikhand";
    rev = "c11c9b0720fba977fad7cb4f339ebacdba1d1394";
    hash = "sha256-cxYS99ZZv3FED7pF91VMiKl/M7Dr5TZr/iAiTuReQbQ=";
  };

  nativeBuildInputs = [ installFonts ];

  meta = {
    description = "Vibrant and playful typeface for both Latin and Gujarati writing systems";
    homepage = "https://jonpinhorn.github.io/shrikhand/";
    license = lib.licenses.ofl;
    maintainers = with lib.maintainers; [ sternenseemann ];
    platforms = lib.platforms.all;
  };
}

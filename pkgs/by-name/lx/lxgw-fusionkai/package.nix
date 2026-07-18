{
  lib,
  fetchFromGitHub,
  installFonts,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation rec {
  pname = "lxgw-fusionkai";
  version = "24.134";

  src = fetchFromGitHub {
    owner = "lxgw";
    repo = "FusionKai";
    rev = "v${version}";
    hash = "sha256-pEISoFEsv8SJOGa2ud/nV1yvl8T9kakfKENu3mfYA5A=";
  };

  nativeBuildInputs = [ installFonts ];

  meta = {
    description = "Simplified Chinese font derived from LXGW WenKai GB, iansui and Klee One";
    homepage = "https://github.com/lxgw/FusionKai";
    license = lib.licenses.ofl;
    maintainers = with lib.maintainers; [ hellodword ];
    platforms = lib.platforms.all;
  };
}

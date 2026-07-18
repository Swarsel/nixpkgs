{
  lib,
  fetchurl,
  installFonts,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation rec {
  pname = "lxgw-wenkai-tc";
  version = "1.522";

  src = fetchurl {
    url = "https://github.com/lxgw/LxgwWenKaiTC/releases/download/v${version}/lxgw-wenkai-tc-v${version}.tar.gz";
    hash = "sha256-E2Z13IOaWwdsAPnHFsYQ2B/d3dhXP4duvdaYO/4PCfg=";
  };

  nativeBuildInputs = [ installFonts ];

  meta = {
    description = "Traditional Chinese Edition of LXGW WenKai";
    homepage = "https://github.com/lxgw/LxgwWenKaiTC";
    license = lib.licenses.ofl;
    maintainers = with lib.maintainers; [ lebensterben ];
    platforms = lib.platforms.all;
  };
}

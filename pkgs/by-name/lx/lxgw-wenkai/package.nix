{
  lib,
  fetchurl,
  installFonts,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation rec {
  pname = "lxgw-wenkai";
  version = "1.522";

  src = fetchurl {
    url = "https://github.com/lxgw/LxgwWenKai/releases/download/v${version}/lxgw-wenkai-v${version}.tar.gz";
    hash = "sha256-aBp31dACF146nhrw/G+iIBZMya1sFPHoQqU5h4584aQ=";
  };

  nativeBuildInputs = [ installFonts ];

  meta = {
    description = "Open-source Chinese font derived from Fontworks' Klee One";
    homepage = "https://lxgw.github.io/";
    license = lib.licenses.ofl;
    maintainers = with lib.maintainers; [ ryanccn ];
    platforms = lib.platforms.all;
  };
}

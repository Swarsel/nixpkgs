{
  lib,
  fetchFromGitHub,
  build-idris-package,
  contrib,
  effects,
  lightyear,
}:
build-idris-package {
  pname = "ipkgparser";
  version = "2017-11-14";

  src = fetchFromGitHub {
    owner = "emptyflash";
    repo = "idris-ipkg-parser";
    rev = "35cc2f54d4f3b3710f637d0a8c897bfbb32fe183";
    sha256 = "0vn3pigqddfy7cld0386hxzdv2nkl8mdpsx97hvyvqzrdpz4wl2q";
  };

  idrisDeps = [
    contrib
    effects
    lightyear
  ];

  meta = {
    description = "Parser for Idris iPkg files written in Idris using Lightyear";
    homepage = "https://github.com/emptyflash/idris-ipkg-parser";
    maintainers = [ lib.maintainers.brainrape ];
  };
}

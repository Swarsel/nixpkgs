{
  lib,
  stdenv,
  fetchFromGitHub,
  bluespec,
  pkg-config,
  readline,
  yosys,
  zlib,
}:

stdenv.mkDerivation {
  pname = "yosys-bluespec";
  version = "2021.09.08";

  src = fetchFromGitHub {
    owner = "thoughtpolice";
    repo = "yosys-bluespec";
    rev = "f6f4127a4e96e18080fd5362b6769fa3e24c76b1";
    sha256 = "sha256-3cNFP/k4JsgLyUQHWU10Htl2Rh0staAcA3R4piD6hDE=";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    yosys
    readline
    zlib
    bluespec
  ];

  makeFlags = [
    "PREFIX=$(out)/share/yosys/plugins"
    "STATIC_BSC_PATH=${bluespec}/bin/bsc"
    "STATIC_BSC_LIBDIR=${bluespec}/lib"
  ];

  doCheck = true;
  plugin = "bluespec";

  meta = {
    description = "Bluespec plugin for Yosys";
    homepage = "https://github.com/thoughtpolice/yosys-bluespec";
    license = lib.licenses.isc;
    maintainers = with lib.maintainers; [ thoughtpolice ];
    platforms = lib.platforms.all;
  };
}

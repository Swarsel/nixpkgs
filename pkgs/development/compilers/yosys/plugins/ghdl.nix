{
  lib,
  stdenv,
  fetchFromGitHub,
  ghdl,
  pkg-config,
  readline,
  yosys,
  zlib,
}:

stdenv.mkDerivation {
  pname = "yosys-ghdl";
  version = "0-unstable-2025-05-23";

  src = fetchFromGitHub {
    owner = "ghdl";
    repo = "ghdl-yosys-plugin";
    rev = "1b97dc71377cea7e861be6625be4353c377a5fb5";
    hash = "sha256-TFMUqIXJzgpnZ8cDlVb47btPqsCNJil0MN4Tdt83140=";
  };

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    yosys
    readline
    zlib
    ghdl
  ];

  doCheck = true;

  installPhase = ''
    mkdir -p $out/share/yosys/plugins
    cp ghdl.so $out/share/yosys/plugins/ghdl.so
  '';

  plugin = "ghdl";

  meta = {
    description = "GHDL plugin for Yosys";
    homepage = "https://github.com/ghdl/ghdl-yosys-plugin";
    license = lib.licenses.isc;
    maintainers = with lib.maintainers; [ thoughtpolice ];
    platforms = lib.platforms.all;
  };
}

{
  lib,
  stdenv,
  fetchFromGitHub,
  automake,
  autoreconfHook,
  cairo,
  ghostscript,
  libice,
  libsm,
  libx11,
  libxpm,
  libxt,
  ngspice,
  pkg-config,
  tcl,
  tk,
  zlib,
}:

stdenv.mkDerivation {
  pname = "xcircuit";
  version = "3.10.42";

  src = fetchFromGitHub {
    owner = "RTimothyEdwards";
    repo = "XCircuit";
    rev = "8a0429250abbd2b70c4d3fbfe2e2c20b4c43be81";
    sha256 = "sha256-ijJYppWuEYcb2RLVsvGHu+7YRp027MNDDcqxSKLHORU=";
  };

  nativeBuildInputs = [
    autoreconfHook
    automake
    pkg-config
  ];

  buildInputs = [
    cairo
    ghostscript
    libsm
    libxt
    libice
    libx11
    libxpm
    tcl
    tk
    zlib
  ];

  configureFlags = [
    "--with-tcl=${tcl}/lib"
    "--with-tk=${tk}/lib"
    "--with-ngspice=${lib.getBin ngspice}/bin/ngspice"
  ];

  hardeningDisable = [ "format" ];

  meta = {
    description = "Generic drawing program tailored to circuit diagrams";
    homepage = "http://opencircuitdesign.com/xcircuit";
    license = lib.licenses.gpl2;

    maintainers = with lib.maintainers; [
      john-shaffer
      spacefrogg
      thoughtpolice
    ];

    platforms = lib.platforms.linux;
    mainProgram = "xcircuit";
  };
}

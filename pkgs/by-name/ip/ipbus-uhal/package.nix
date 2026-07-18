{
  lib,
  stdenv,
  fetchFromGitHub,
  bash,
  boost186,
  cacert,
  pugixml,
  python3,
  python3Packages,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ipbus-uhal";
  version = "2.8.16";

  src = fetchFromGitHub {
    owner = "ipbus";
    repo = "ipbus-software";
    rev = "v${finalAttrs.version}";
    hash = "sha256-R+a9VmONyWh3BEYoMjRcXKv+3HaNcKbJDnYH1hXHdPg=";
  };

  postPatch = ''
    substituteInPlace config/Makefile.macros --replace-fail \
      'SHELL := /bin/bash' ""
    patchShebangs --build uhal/config/install.sh
    patchShebangs --build uhal/tests/setup.sh
    patchShebangs --build scripts/doxygen/api_uhal.sh
    patchShebangs --build config/progress.sh
    patchShebangs --build config/Makefile.macros
  '';

  nativeBuildInputs = [
    cacert
    (python3.withPackages (ps: [
      ps.distutils
      ps.pybind11
    ]))
  ];

  buildInputs = [
    boost186
    pugixml
    python3.pkgs.distutils
    python3.pkgs.pybind11
  ];

  makeFlags = [
    "Set=uhal"
    "CXX=${stdenv.cc.targetPrefix}c++"
  ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/{bin,include}
    make Set=uhal install prefix=$out/bin includedir=$out/include
    runHook postInstall
  '';

  enableParallelBuilding = true;

  meta = {
    description = "Software which pairs with ipbus-firmware";

    longDescription = ''
      Software that provide a reliable high-performance
      control link for particle-physics or other electronics,
      by implementing a simple A32/D32 control protocol
      for reading and modifying memory-mapped resources
      within FPGA-based hardware devices.
    '';

    homepage = "https://ipbus.web.cern.ch/";
    maintainers = [ lib.maintainers.bashsu ];
    platforms = lib.platforms.linux;
    mainProgram = "ipbus-uhal";
  };
})

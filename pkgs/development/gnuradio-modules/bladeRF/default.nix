{
  lib,
  fetchFromGitHub,
  boost,
  cmake,
  doxygen,
  gmp,
  gnuradio,
  libbladeRF,
  mkDerivation,
  mpir,
  osmosdr,
  pkg-config,
  python,
  spdlog,
}:

mkDerivation {
  pname = "gr-bladeRF";
  version = "0-unstable-2023-11-20";

  src = fetchFromGitHub {
    owner = "Nuand";
    repo = "gr-bladeRF";
    rev = "27de2898dbee75d55c61f541315e3853e602e526";
    hash = "sha256-josovHEp2VxgZqItkTAISdY1LARMIvQKD604fh4iZWc=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
  ]
  ++ lib.optionals (gnuradio.hasFeature "python-support") [
    python.pkgs.mako
    python.pkgs.pygccxml
  ];

  buildInputs = [
    boost
    doxygen
    gmp
    gnuradio
    libbladeRF
    mpir
    osmosdr
    spdlog
  ]
  ++ lib.optionals (gnuradio.hasFeature "python-support") [
    python.pkgs.numpy
    python.pkgs.pybind11
  ];

  cmakeFlags = [
    (lib.cmakeBool "ENABLE_PYTHON" (gnuradio.hasFeature "python-support"))
  ];

  meta = {
    description = "GNU Radio source and sink blocks for bladeRF devices";
    homepage = "https://github.com/Nuand/gr-bladeRF";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ wucke13 ];
    platforms = lib.platforms.linux;
  };
}

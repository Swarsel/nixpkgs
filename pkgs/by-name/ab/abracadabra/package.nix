{
  lib,
  stdenv,
  fetchFromGitHub,
  airspy,
  cmake,
  faad2,
  libusb1,
  mpg123,
  portaudio,
  qt6,
  rtl-sdr,
  soapysdr-with-plugins,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "abracadabra";
  version = "4.1.1";

  src = fetchFromGitHub {
    owner = "KejPi";
    repo = "AbracaDABra";
    tag = "v${finalAttrs.version}";
    hash = "sha256-6MraWIon5bqLmqwLodZXys4Lz+kamFhIa03+eVsApqk=";
  };

  nativeBuildInputs = [
    cmake
    qt6.wrapQtAppsHook
    qt6.qttools
  ];

  buildInputs = [
    qt6.qtbase
    qt6.qtmultimedia
    qt6.qtlocation
    qt6.qtpositioning
    faad2
    mpg123
    portaudio
    libusb1
    rtl-sdr
    airspy
    soapysdr-with-plugins
  ];

  cmakeFlags = [
    "-DAIRSPY=ON"
    "-DSOAPYSDR=ON"
  ];

  meta = {
    description = "DAB/DAB+ radio application";
    homepage = "https://github.com/KejPi/AbracaDABra";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ markuskowa ];
    platforms = lib.platforms.linux;
    mainProgram = "AbracaDABra";
  };
})

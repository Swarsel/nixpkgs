{
  lib,
  stdenv,
  fetchFromGitHub,
  boost,
  cmake,
  desktopToDarwinBundle,
  fftw,
  libsForQt5,
  libusb1,
  libzip,
  pkg-config,
  python3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "dsview";
  version = "1.3.2";

  src = fetchFromGitHub {
    owner = "DreamSourceLab";
    repo = "DSView";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-d/TfCuJzAM0WObOiBhgfsTirlvdROrlCm+oL1cqUrIs=";
  };

  patches = [
    # Fix absolute install paths
    ./install.patch
    ./cmake4.patch
  ];

  nativeBuildInputs = [
    cmake
    pkg-config
    libsForQt5.wrapQtAppsHook
  ]
  ++ lib.optional stdenv.hostPlatform.isDarwin desktopToDarwinBundle;

  buildInputs = [
    boost
    fftw
    libsForQt5.qtbase
    libsForQt5.qtsvg
    libusb1
    libzip
    python3
  ]
  ++ lib.optional stdenv.hostPlatform.isLinux libsForQt5.qtwayland;

  # /build/source/libsigrok4DSL/strutil.c:343:19: error: implicit declaration of function 'strcasecmp'; did you mean 'g_strcasecmp'? []
  env.NIX_CFLAGS_COMPILE = "-Wno-error=implicit-function-declaration";
  doInstallCheck = true;

  meta = {
    description = "GUI program for supporting various instruments from DreamSourceLab, including logic analyzer, oscilloscope, etc";
    homepage = "https://www.dreamsourcelab.com/";
    license = lib.licenses.gpl3Plus;

    maintainers = with lib.maintainers; [
      bachp
      carlossless
    ];

    platforms = lib.platforms.unix;
    mainProgram = "DSView";
  };
})

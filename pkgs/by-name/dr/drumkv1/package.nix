{
  lib,
  stdenv,
  fetchurl,
  alsa-lib,
  cmake,
  libjack2,
  liblo,
  libsndfile,
  libx11,
  lv2,
  pkg-config,
  qt6,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "drumkv1";
  version = "1.4.2";

  src = fetchurl {
    url = "mirror://sourceforge/drumkv1/drumkv1-${finalAttrs.version}.tar.gz";
    hash = "sha256-jTOTOziCrycFyMe6wIfUnw7d6p+gNZfO7Q9BcZOyOME=";
  };

  nativeBuildInputs = [
    pkg-config
    cmake
    qt6.wrapQtAppsHook
  ];

  buildInputs = [
    libjack2
    alsa-lib
    libsndfile
    liblo
    lv2
    libx11
    qt6.qtbase
    qt6.qtwayland
    qt6.qtsvg
  ];

  cmakeFlags = [
    # disable experimental feature "LV2 port change request"
    "-DCONFIG_LV2_PORT_CHANGE_REQUEST=false"
    # override libdir -- temporary until upstream fixes CMakeLists.txt
    "-DCMAKE_INSTALL_LIBDIR=lib"
  ];

  meta = {
    description = "Old-school drum-kit sampler synthesizer with stereo fx";
    homepage = "http://drumkv1.sourceforge.net/";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ theredstonedev ];
    platforms = lib.platforms.linux;
    mainProgram = "drumkv1_jack";
  };
})

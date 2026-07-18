{
  lib,
  stdenv,
  fetchurl,
  SDL2,
  alsa-lib,
  cmake,
  config,
  ffmpeg,
  gsl,
  gtk3,
  intltool,
  libpng,
  libpulseaudio,
  libsForQt5,
  libusb1,
  libv4l,
  pkg-config,
  portaudio,
  sfml_2,
  udev,
  pulseaudioSupport ? config.pulseaudio or stdenv.hostPlatform.isLinux,
  # can be turned off if used as a library
  useGtk ? true,
  useQt ? false,
  wrapGAppsHook3 ? null,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "guvcview";
  version = "2.2.2";

  src = fetchurl {
    url = "mirror://sourceforge/project/guvcview/source/guvcview-src-${finalAttrs.version}.tar.bz2";
    hash = "sha256-ahsTSLmeedqVeg2eI3OVpUdXoJ234MCAn2wwZotp2js=";
  };

  nativeBuildInputs = [
    intltool
    pkg-config
    cmake
  ]
  ++ lib.optionals useGtk [ wrapGAppsHook3 ]
  ++ lib.optionals useQt [ libsForQt5.wrapQtAppsHook ];

  buildInputs = [
    SDL2
    alsa-lib
    ffmpeg
    libusb1
    libv4l
    portaudio
    udev
    gsl
    libpng
    sfml_2
  ]
  ++ lib.optionals pulseaudioSupport [ libpulseaudio ]
  ++ lib.optionals useGtk [ gtk3 ]
  ++ lib.optionals useQt [
    libsForQt5.qtbase
  ];

  configureFlags = [
    "--enable-sfml"
  ]
  ++ lib.optionals useGtk [ "--enable-gtk3" ]
  ++ lib.optionals useQt [ "--enable-qt5" ];

  meta = {
    description = "Simple interface for devices supported by the linux UVC driver";
    homepage = "https://guvcview.sourceforge.net";
    license = lib.licenses.gpl3;
    maintainers = [ lib.maintainers.coconnor ];
    platforms = lib.platforms.linux;
    mainProgram = "guvcview";
  };
})

{
  lib,
  stdenv,
  fetchurl,
  SDL,
  SDL_image,
  alsa-lib,
  bison,
  curl,
  desktop-file-utils,
  dos2unix,
  file,
  flex,
  giflib,
  glew,
  gtk3,
  libGL,
  libGLU,
  libevdev,
  libpng,
  perl,
  pkg-config,
  pulseaudio,
  readline,
  wrapGAppsHook3,
  xa,
  xdg-utils,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "vice";
  version = "3.10";

  src = fetchurl {
    url = "mirror://sourceforge/vice-emu/vice-${finalAttrs.version}.tar.gz";
    sha256 = "sha256-jlusGMvLnxkjgK0++IH4eQ9bdcQdez2mXYMZhdhk1tE=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    bison
    desktop-file-utils
    dos2unix
    file
    flex
    perl
    pkg-config
    wrapGAppsHook3
    xa
    xdg-utils
  ];

  buildInputs = [
    alsa-lib
    curl
    giflib
    glew
    gtk3
    libevdev
    libGL
    libGLU
    libpng
    pulseaudio
    readline
    SDL
    SDL_image
  ];

  configureFlags = [
    "--enable-sdl2ui"
    "--enable-gtk3ui"
    "--enable-desktop-files"
    "--disable-pdf-docs"
    "--with-gif"
  ];

  env.LIBS = "-lGL";

  preConfigure = ''
    patchShebangs .
  '';

  preInstall = ''
    # env var for `desktop-file-install`
    export DESKTOP_FILE_INSTALL_DIR=$out/share/applications
    mkdir -p $DESKTOP_FILE_INSTALL_DIR
  '';

  postInstall = ''
    for binary in vsid x128 x64 x64dtv xcbm2 xpet xplus4 xscpu64 xvic; do
      for size in 16 24 32 48 64 256; do
        install -D data/common/vice-''${binary}_''${size}.png $out/share/icons/hicolor/''${size}x''${size}/apps/vice-''${binary}.png
      done
      install -D data/common/vice-''${binary}_1024.svg $out/share/icons/hicolor/scalable/apps/vice-''${binary}.svg
    done
  '';

  enableParallelBuilding = true;

  meta = {
    description = "Emulators for a variety of 8-bit Commodore computers";
    homepage = "https://vice-emu.sourceforge.io/";
    license = lib.licenses.gpl2Plus;
    maintainers = [ lib.maintainers.nekowinston ];
    platforms = lib.platforms.linux;
  };
})

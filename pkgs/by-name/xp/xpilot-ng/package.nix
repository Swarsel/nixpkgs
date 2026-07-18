{
  lib,
  stdenv,
  fetchurl,
  SDL,
  SDL_image,
  SDL_ttf,
  expat,
  libGL,
  libGLU,
  libsm,
  libx11,
  libxext,
  libxxf86misc,
  zlib,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "xpilot-ng";
  version = "4.7.3";

  src = fetchurl {
    url = "mirror://sourceforge/xpilot/xpilot_ng/xpilot-ng-${finalAttrs.version}/xpilot-ng-${finalAttrs.version}.tar.gz";
    hash = "sha256-8ocJPHV6cSMgAPIQ7kpO3szJ6K8IF9W+QwhOhK69Rwk=";
  };

  patches = [
    ./xpilot-ng-gcc-14-fix.patch
    ./xpilot-ng-sdl-window-fix.patch
    ./xpilot-ng-gcc-15-fix.patch
  ];

  buildInputs = [
    libx11
    libsm
    libxext
    SDL
    SDL_ttf
    SDL_image
    libGLU
    libGL
    expat
    zlib
    libxxf86misc
  ];

  meta = {
    description = "Multiplayer X11 space combat game";
    homepage = "http://xpilot.sf.net/";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ raskin ];
    platforms = lib.platforms.linux;
  };
})

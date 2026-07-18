{
  lib,
  stdenv,
  fetchurl,
  fetchpatch,
  freealut,
  libGLU,
  libglut,
  libice,
  libpng,
  libsm,
  libvorbis,
  libx11,
  libxext,
  libxi,
  libxrandr,
  libxrender,
  libxt,
  libxxf86vm,
  openal,
  plib,
  xorgproto,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "torcs-without-data";
  version = "1.3.9";

  src = fetchurl {
    url = "mirror://sourceforge/torcs/all-in-one/${finalAttrs.version}/torcs-${finalAttrs.version}.tar.bz2";
    sha256 = "sha256-+caehtKQKVRnRRsB14ONhQBbphNkSm/oo/hafGoDzUw=";
  };

  patches = [
    (fetchpatch {
      sha256 = "04advcx88yh23ww767iysydzhp370x7cqp2wf9hk2y1qvw7mxsja";
      url = "https://salsa.debian.org/games-team/torcs/raw/fb0711c171b38c4648dc7c048249ec20f79eb8e2/debian/patches/format-argument.patch";
    })
  ];

  postPatch = ''
    sed -i -e s,/bin/bash,`type -P bash`, src/linux/torcs.in
  '';

  buildInputs = [
    libGLU
    libglut
    libx11
    plib
    openal
    freealut
    libxrandr
    xorgproto
    libxext
    libsm
    libice
    libxi
    libxt
    libxrender
    libxxf86vm
    libpng
    zlib
    libvorbis
  ];

  meta = {
    description = "Car racing game (does not come with the game data required to run)";
    homepage = "https://torcs.sourceforge.net/";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ pixel-87 ];
    platforms = lib.platforms.linux;
  };
})

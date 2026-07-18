{
  lib,
  stdenv,
  fetchurl,
  fetchpatch,
  gettext,
  libice,
  libpng12,
  libsm,
  libx11,
  libxext,
  xorgproto,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "lincity";
  version = "1.13.1";

  src = fetchurl {
    url = "mirror://sourceforge/lincity/lincity-${finalAttrs.version}.tar.gz";
    hash = "sha256-e0y9Ef/Uy+15oKrbJfKxw04lqCARgvuyWc4vRQ/lAV0=";
  };

  patches = [
    (fetchpatch {
      hash = "sha256-4LKZuUztvfOUhkKwjZJnku1yfBVSqT5Uybx8MPkftxk=";
      url = "https://sources.debian.net/data/main/l/lincity/1.13.1-13/debian/patches/extern-inline-functions-777982";
    })
    (fetchpatch {
      hash = "sha256-91mzptO37x1UfY6pa6CrEkSkfhu1KNJDqIB5zbi3GSU=";
      url = "https://sources.debian.net/data/main/l/lincity/1.13.1-13/debian/patches/clang-ftbfs-757859";
    })
    (fetchpatch {
      hash = "sha256-S9TQ7KcmGGsQeTKLXqF/9FDXv/+WjrEPL4ly7DSki1s=";
      url = "https://sources.debian.org/data/main/l/lincity/1.13.1-16/debian/patches/fix-implicit-declarations-823432";
    })
    (fetchpatch {
      hash = "sha256-KlmXBWPI8lFWO8kPA78uG52DCs8NeGmNNFpZYfCwo5M=";
      url = "https://sources.debian.org/data/main/l/lincity/1.13.1-16/debian/patches/fix-implicit-function-declarations-1066295";
    })
    (fetchpatch {
      hash = "sha256-IxstC74R7kige0ormFLGEj4uzbJt/b8bLmygheN08II=";
      url = "https://sources.debian.org/data/main/l/lincity/1.13.1-16/debian/patches/delay_timers";
    })
    (fetchpatch {
      hash = "sha256-9qLPrmEKMMrSVwqtEvoiyjPPo1eLO3u6bCJslubmBJU=";
      url = "https://sources.debian.org/data/main/l/lincity/1.13.1-16/debian/patches/map-max-draw";
    })
    (fetchpatch {
      hash = "sha256-6fwDIX88dCpAFE02Z4Ts5gsMf3wwxrToEwpy0DwZ6H4=";
      url = "https://sources.debian.org/data/main/l/lincity/1.13.1-17/debian/patches/function-pointer-1097300";
    })
  ];

  postPatch = ''
    sed -e 's@\[MPS_INFO_CHARS\]@[MPS_INFO_CHARS+8]@' -i mps.c -i mps.h

    ${lib.optionalString stdenv.hostPlatform.isDarwin ''
      sed -i '/\#include \"malloc.h\"/d' readpng.c
    ''}
  '';

  nativeBuildInputs = lib.optionals stdenv.hostPlatform.isDarwin [ gettext ];

  buildInputs = [
    libice
    libpng12
    libsm
    libx11
    libxext
    xorgproto
    zlib
  ];

  # Workaround build failure on -fno-common toolchains like upstream
  # gcc-10. Otherwise build fails as:
  #   ld: modules/.libs/libmodules.a(rocket_pad.o):/build/lincity-1.13.1/modules/../screen.h:23:
  #     multiple definition of `monthgraph_style'; ldsvguts.o:/build/lincity-1.13.1/screen.h:23: first defined here
  env.NIX_CFLAGS_COMPILE = "-fcommon";

  meta = {
    description = "City simulation game";
    homepage = "https://sourceforge.net/projects/lincity";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ iedame ];
    mainProgram = "xlincity";
  };
})

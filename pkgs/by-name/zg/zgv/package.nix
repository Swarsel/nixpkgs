{
  lib,
  stdenv,
  fetchurl,
  SDL_image,
  SDL_sixel,
  fetchpatch,
  libjpeg,
  libpng,
  libtiff,
  pkg-config,
}:

let
  # Enable terminal display. Note that it requires sixel graphics compatible
  # terminals like mlterm or xterm -ti 340
  SDL_image_sixel = SDL_image.override {
    SDL = SDL_sixel;
  };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "zgv";
  version = "5.9";

  src = fetchurl {
    url = "https://www.svgalib.org/rus/zgv/${finalAttrs.pname}-${finalAttrs.version}.tar.gz";
    sha256 = "1fk4i9x0cpnpn3llam0zy2pkmhlr2hy3iaxhxg07v9sizd4dircj";
  };

  patches = [
    ./add-include.patch
    (fetchpatch {
      sha256 = "1blw9n04c28bnwcmcn64si4f5zpg42s8yn345js88fyzi9zm19xw";
      url = "https://foss.aueb.gr/mirrors/linux/gentoo/media-gfx/zgv/files/zgv-5.9-libpng15.patch";
    })
    ./switch.patch
  ];

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    SDL_sixel
    SDL_image_sixel
    libjpeg
    libpng
    libtiff
  ];

  makeFlags = [
    "BACKEND=SDL"
  ];

  # gcc15
  env.NIX_CFLAGS_COMPILE = "-std=gnu17";

  installPhase = ''
    mkdir -p $out/bin
    cp src/zgv $out/bin
  '';

  hardeningDisable = [ "format" ];
  patchFlags = [ "-p0" ];

  meta = {
    description = "Picture viewer with a thumbnail-based selector";
    homepage = "http://www.svgalib.org/rus/zgv/";
    license = lib.licenses.gpl2;
    maintainers = [ ];
    platforms = lib.platforms.linux;
    mainProgram = "zgv";
  };
})

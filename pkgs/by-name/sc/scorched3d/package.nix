{
  lib,
  stdenv,
  fetchurl,
  SDL,
  SDL_net,
  expat,
  fftwSinglePrec,
  freealut,
  freetype,
  glew,
  libGL,
  libGLU,
  libjpeg,
  libogg,
  libpng,
  libvorbis,
  openal-soft,
  pkg-config,
  wxwidgets_3_2,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "scorched3d";
  version = "44";

  src = fetchurl {
    url = "mirror://sourceforge/scorched3d/Scorched3D-${finalAttrs.version}-src.tar.gz";
    sha256 = "1fldi9pn7cz6hc9h70pacgb7sbykzcac44yp3pkhn0qh4axj10qw";
  };

  patches = [
    ./file-existence.patch
    (fetchurl {
      sha256 = "1farmjxbc2wm4scsdbdnvh29fipnb6mp6z85hxz4bx6n9kbc8y7n";
      url = "https://gitweb.gentoo.org/repo/gentoo.git/plain/games-strategy/scorched3d/files/scorched3d-44-fix-c++14.patch?id=1bbcfc9ae3dfdfcbdd35151cb7b6050776215e4d";
    })
    (fetchurl {
      sha256 = "sha256-Y5U5yYNT5iMqhdRaDMFtZ4K7aD+pugFZP0jLh7rdDp8=";
      url = "https://sources.debian.org/data/main/s/scorched3d/44%2Bdfsg-7/debian/patches/wx3.0-compat.patch";
    })
    ./gcc14-fix.patch
  ];

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    libGLU
    libGL
    glew
    openal-soft
    freealut
    wxwidgets_3_2
    libogg
    freetype
    libvorbis
    SDL
    SDL_net
    expat
    libjpeg
    libpng
    fftwSinglePrec
  ];

  configureFlags = [ "--with-fftw=${fftwSinglePrec.dev}" ];
  env.NIX_LDFLAGS = "-lopenal";
  sourceRoot = "scorched";

  meta = {
    description = "3D Clone of the classic Scorched Earth";
    homepage = "http://scorched3d.co.uk/";
    license = lib.licenses.gpl2Plus;
    maintainers = [ ];
    platforms = lib.platforms.linux; # maybe more
  };
})

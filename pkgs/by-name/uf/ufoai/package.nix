{
  lib,
  stdenv,
  fetchurl,
  SDL,
  SDL_mixer,
  SDL_ttf,
  cunit,
  curl,
  gettext,
  libGL,
  libGLU,
  libjpeg,
  libpng,
  libtheora,
  xvidcore,
  enableEditor ? false,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ufoai";
  version = "2.4";

  src = fetchurl {
    url = "mirror://sourceforge/ufoai/ufoai-${finalAttrs.version}-source.tar.bz2";
    sha256 = "0kxrbcjrharcwz319s90m789i4my9285ihp5ax6kfhgif2vn2ji5";
  };

  buildInputs = [
    libtheora
    xvidcore
    libGLU
    libGL
    SDL
    SDL_ttf
    SDL_mixer
    curl
    libjpeg
    libpng
    gettext
    cunit
  ];

  configureFlags = [
    "--enable-release"
    "--enable-sse"
  ]
  ++ lib.optional enableEditor "--enable-uforadiant";

  env = {
    # Workaround build failure on -fno-common toolchains:
    #   ld: r_gl.h:52: multiple definition of `qglGenBuffers';
    #     r_gl.h:52: first defined here
    # TODO: drop once release contains upstream fix:
    #   https://github.com/ufoai/ufoai/commit/8a3075fffdad294e
    NIX_CFLAGS_COMPILE = "-fcommon";

    NIX_CFLAGS_LINK = toString [
      # to avoid occasional runtime error in finding libgcc_s.so.1
      "-lgcc_s"
      # tests are underlinked against libm:
      # ld: release-linux-x86_64/testall/client/sound/s_mix.c.o: undefined reference to symbol 'acos@@GLIBC_2.2.5'
      "-lm"
    ];
  };

  preConfigure = ''tar xvf "${finalAttrs.srcData}"'';

  srcData = fetchurl {
    sha256 = "1drhh08cqqkwv1yz3z4ngkplr23pqqrdx6cp8c3isy320gy25cvb";
    url = "mirror://sourceforge/ufoai/ufoai-${finalAttrs.version}-data.tar";
  };

  meta = {
    description = "Squad-based tactical strategy game in the tradition of X-Com";
    homepage = "http://ufoai.org";
    license = lib.licenses.gpl2Plus;
    maintainers = [ ];
    platforms = lib.platforms.linux;
    hydraPlatforms = [ ];
  };
})

{
  lib,
  stdenv,
  fetchurl,
  SDL,
  fetchpatch,
  libGL,
  libGLU,
  libglut,
  libsm,
  libx11,
  libxext,
  libxi,
  libxmu,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "plib";
  version = "1.8.5";

  src = fetchurl {
    # XXX: The author doesn't use the orthodox SF way to store tarballs.
    url = "https://plib.sourceforge.net/dist/plib-${finalAttrs.version}.tar.gz";
    sha256 = "0cha71mflpa10vh2l7ipyqk67dq2y0k5xbafwdks03fwdyzj4ns8";
  };

  patches = [
    (fetchpatch {
      sha256 = "1b7y0vqqdzd48q68ldlzw0zzqy9mg4c10a754r4hi3ldjmcplf0j";
      url = "https://sources.debian.net/data/main/p/plib/1.8.5-7/debian/patches/04_CVE-2011-4620.diff";
    })
    (fetchpatch {
      sha256 = "0b6cwdwii5b5vy78sbw5cw1s96l4jyzr4dk69v63pa0wwi2b5dki";
      url = "https://sources.debian.net/data/main/p/plib/1.8.5-7/debian/patches/05_CVE-2012-4552.diff";
    })
    (fetchpatch {
      sha256 = "sha256-3f1wZn0QqK/hPWCg1KEzbB95IGoxBjLZoCOFlW98t5w=";
      url = "https://sources.debian.org/data/main/p/plib/1.8.5-13/debian/patches/08_CVE-2021-38714.patch";
    })
    ./darwin-ssgloadflt-uint.patch
  ];

  propagatedBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    libGLU
    libGL
    libglut
    SDL

    # The following libs ought to be propagated build inputs of Mesa.
    libxi
    libsm
    libxmu
    libxext
    libx11
  ];

  configureFlags = lib.optionals stdenv.hostPlatform.isDarwin [
    "--disable-sl"
    "--disable-pw"
  ];

  meta = {
    description = "Suite of portable game libraries";

    longDescription = ''
      PLIB includes sound effects, music, a complete 3D engine, font
      rendering, a simple Windowing library, a game scripting
      language, a GUI, networking, 3D math library and a collection of
      handy utility functions.  All are 100% portable across nearly
      all modern computing platforms.  What's more, it's all available
      on line - and completely free.  Each library component is fairly
      independent of the others - so if you want to use SDL, GTK,
      GLUT, or FLTK instead of PLIB's 'PW' windowing library, you can.
    '';

    homepage = "https://plib.sourceforge.net/";
    license = lib.licenses.lgpl2Plus;
    platforms = lib.platforms.unix;
  };
})

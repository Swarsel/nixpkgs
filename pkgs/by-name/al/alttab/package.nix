{
  lib,
  stdenv,
  fetchFromGitHub,
  autoconf,
  automake,
  coreutils,
  fetchpatch,
  libpng,
  libx11,
  libxft,
  libxmu,
  libxpm,
  libxrandr,
  libxrender,
  pkg-config,
  procps,
  python3Packages,
  ronn,
  uthash,
  which,
  xeyes,
  xnee,
  xprop,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "alttab";
  version = "1.7.1";

  src = fetchFromGitHub {
    owner = "sagb";
    repo = "alttab";
    tag = "v${finalAttrs.version}";
    sha256 = "sha256-1+hk0OeSriXPyefv3wOgeiW781PL4VP5Luvt+RS5jmg=";
  };

  patches = [
    # Fix gcc-15 build failure: https://github.com/sagb/alttab/pull/178
    (fetchpatch {
      hash = "sha256-7l74kXs0bAyozBbgOEzDSY+4NE2pjdVfWda0XiPvCz4=";
      name = "gcc-15.patch";
      url = "https://github.com/sagb/alttab/commit/665e3e369f74ab0075c22a46a3cb3a9f76bdd762.patch";
    })
  ];

  nativeBuildInputs = [
    autoconf
    automake
    pkg-config
    ronn
  ];

  buildInputs = [
    libpng
    uthash
    libx11
    libxft
    libxmu
    libxpm
    libxrandr
    libxrender
  ];

  preConfigure = "./bootstrap.sh";
  doCheck = true;

  nativeCheckInputs = [
    coreutils
    procps
    python3Packages.xvfbwrapper
    which
    xnee
    xeyes
    xprop
  ];

  enableParallelBuilding = true;

  meta = {
    description = "X11 window switcher designed for minimalistic window managers or standalone X11 session";
    homepage = "https://github.com/sagb/alttab";
    license = lib.licenses.gpl3Plus;
    maintainers = [ ];
    platforms = lib.platforms.all;
    mainProgram = "alttab";
  };
})

{
  lib,
  stdenv,
  fetchurl,
  freetype,
  fribidi,
  imlib2,
  libxext,
  libxft,
  libxinerama,
  libxpm,
  libxrandr,
  libxrender,
  pkg-config,
  xorgproto,
}:

stdenv.mkDerivation rec {

  pname = "fluxbox";
  version = "1.3.7";

  src = fetchurl {
    url = "mirror://sourceforge/fluxbox/fluxbox-${version}.tar.xz";
    sha256 = "1h1f70y40qd225dqx937vzb4k2cz219agm1zvnjxakn5jkz7b37w";
  };

  patches = [
    # Upstream fix to build against gcc-11.
    (fetchurl {
      name = "gcc-11.patch";
      sha256 = "1x7126rlmzky51lk370fczssgnjs7i6wgfaikfib9pvn4vv945ai";
      url = "http://git.fluxbox.org/fluxbox.git/patch/?id=22866c4d30f5b289c429c5ca88d800200db4fc4f";
    })
  ];

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    freetype
    fribidi
    libxext
    libxft
    libxpm
    libxrandr
    libxrender
    xorgproto
    libxinerama
    imlib2
  ];

  preConfigure = ''
    substituteInPlace util/fluxbox-generate_menu.in \
      --subst-var-by PREFIX "$out"
  '';

  enableParallelBuilding = true;

  meta = {
    description = "Full-featured, light-resource X window manager";

    longDescription = ''
      Fluxbox is a X window manager based on Blackbox 0.61.1 window
      manager sources.  It is very light on resources and easy to
      handle but yet full of features to make an easy, and extremely
      fast, desktop experience. It is written in C++ and licensed
      under MIT license.
    '';

    homepage = "https://fluxbox.org/";
    license = lib.licenses.mit;
    maintainers = [ ];
    platforms = lib.platforms.linux;
  };
}
# Many thanks Jack Ryan from Nix-dev mailing list!

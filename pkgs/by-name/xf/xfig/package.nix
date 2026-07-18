{
  lib,
  stdenv,
  fetchurl,
  fetchpatch,
  fig2dev,
  imagemagick,
  libxaw,
  libxaw3d,
  libxft,
  libxi,
  libxmu,
  libxp,
  libxpm,
  makeWrapper,
}:

stdenv.mkDerivation rec {
  pname = "xfig";
  version = "3.2.9a";

  src = fetchurl {
    url = "mirror://sourceforge/mcj/xfig-${version}.tar.xz";
    hash = "sha256-vFcqGIHl4gmHrFkBWLBBq3gDhFqWkQNtO6XpgvZtnKM=";
  };

  # Upstream-accepted patches for C23 compatibility from Gentoo and Debian
  patches = [
    (fetchpatch {
      hash = "sha256-brUonsrWP97QnIkHnAHa2PSAiV9JUVOzmu0kvuLNFGw=";
      url = "https://www-user.tu-chemnitz.de/~hamari/distfiles/xfig-3.2.9a-modern-c.patch";
    })
    (fetchpatch {
      hash = "sha256-cMUyp/93bCva4gT349IThhuYmOGZBd0EZ38Y4JrxZn8=";
      url = "https://sources.debian.org/data/main/x/xfig/1%3A3.2.9a-4/debian/patches/19_boolean.patch";
    })
  ];

  postPatch = ''
    substituteInPlace src/main.c --replace-fail '"fig2dev"' '"${fig2dev}/bin/fig2dev"'
  '';

  nativeBuildInputs = [
    imagemagick
    makeWrapper
  ];

  buildInputs = [
    libxpm
    libxmu
    libxi
    libxp
    libxaw3d
    libxaw
    libxft
  ];

  postInstall = ''
    mkdir -p $out/share/X11/app-defaults
    cp app-defaults/* $out/share/X11/app-defaults

    wrapProgram $out/bin/xfig \
      --set XAPPLRESDIR $out/share/X11/app-defaults

    mkdir -p $out/share/icons/hicolor/{16x16,22x22,48x48,64x64}/apps

    for dimension in 16x16 22x22 48x48; do
      magick convert doc/html/images/xfig-logo.png -geometry $dimension\
        $out/share/icons/hicolor/16x16/apps/xfig.png
    done
    install doc/html/images/xfig-logo.png \
      $out/share/icons/hicolor/64x64/apps/xfig.png
  '';

  enableParallelBuilding = true;

  meta = {
    inherit (fig2dev.meta)
      license
      homepage
      platforms
      maintainers
      ;

    description = "Interactive drawing tool for X11";

    longDescription = ''
      Note that you need to have the <literal>netpbm</literal> tools
      in your path to export bitmaps.
    '';

    changelog = "https://sourceforge.net/p/mcj/xfig/ci/${version}/tree/CHANGES";
    mainProgram = "xfig";
  };
}

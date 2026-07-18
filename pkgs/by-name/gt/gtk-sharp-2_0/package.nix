{
  lib,
  stdenv,
  fetchFromGitHub,
  autoconf,
  automake,
  fetchpatch,
  glib,
  gtk2,
  libtool,
  libxml2,
  mono,
  monoDLLFixer,
  pango,
  pkg-config,
  which,
}:

stdenv.mkDerivation (finalAttrs: {
  inherit monoDLLFixer;
  pname = "gtk-sharp";
  version = "2.12.45";

  src = fetchFromGitHub {
    owner = "mono";
    repo = "gtk-sharp";
    rev = finalAttrs.version;
    sha256 = "1vy6yfwkfv6bb45bzf4g6dayiqkvqqvlr02rsnhd10793hlpqlgg";
  };

  patches = [
    (fetchpatch {
      sha256 = "bjx+OfgWnN8SO82p8G7pbGuxJ9EeQxMLeHnrtEm8RV8=";
      url = "https://projects.archlinux.de/svntogit/packages.git/plain/trunk/gtk-sharp2-2.12.12-gtkrange.patch?h=packages/gtk-sharp-2";
    })
  ];

  nativeBuildInputs = [
    pkg-config
    autoconf
    automake
    libtool
    which
  ];

  buildInputs = [
    mono
    glib
    pango
    gtk2
    libxml2
  ];

  env.NIX_CFLAGS_COMPILE = "-Wno-error=int-conversion";

  preConfigure = ''
    ./bootstrap-${lib.versions.majorMinor finalAttrs.version}
  '';

  postInstall = ''
    pushd $out/bin
    for f in gapi2-*
    do
      substituteInPlace $f --replace mono ${mono}/bin/mono
    done
    popd
  '';

  builder = ./builder.sh;
  dontStrip = true;

  passthru = {
    gtk = gtk2;
  };

  meta = {
    description = "Graphical User Interface Toolkit for mono and .Net";
    homepage = "https://www.mono-project.com/docs/gui/gtksharp";
    license = lib.licenses.gpl2;
    platforms = lib.platforms.unix;
  };
})

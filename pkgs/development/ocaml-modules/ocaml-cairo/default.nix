{
  lib,
  stdenv,
  fetchurl,
  autoconf,
  automake,
  cairo,
  findlib,
  freetype,
  gdk-pixbuf,
  gnum4,
  gtk2,
  lablgtk,
  ocaml,
  pango,
  pkg-config,
  unzip,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ocaml-cairo";
  version = "1.2.0";

  src = fetchurl {
    url = "http://cgit.freedesktop.org/cairo-ocaml/snapshot/cairo-ocaml-${finalAttrs.version}.zip";
    sha256 = "0l4p9bp6kclr570mxma8wafibr1g5fsjj8h10yr4b507g0hmlh0l";
  };

  patches = [ ./META.patch ];
  strictDeps = true;

  nativeBuildInputs = [
    pkg-config
    unzip
    ocaml
    automake
    gnum4
    autoconf
    findlib
  ];

  buildInputs = [
    freetype
    lablgtk
    cairo
    gdk-pixbuf
    gtk2
    pango
  ];

  makeFlags = [ "INSTALLDIR=$(out)/lib/ocaml/${ocaml.version}/site-lib/cairo" ];

  preConfigure = ''
    aclocal -I support
    autoconf
    export NIX_CFLAGS_COMPILE="$NIX_CFLAGS_COMPILE `pkg-config --cflags cairo gdk-pixbuf glib gtk+ pango`"
    export LABLGTKDIR=${lablgtk}/lib/ocaml/${ocaml.version}/site-lib/lablgtk2
    cp ${lablgtk}/lib/ocaml/${ocaml.version}/site-lib/lablgtk2/pango.ml ./src
    cp ${lablgtk}/lib/ocaml/${ocaml.version}/site-lib/lablgtk2/gaux.ml ./src
  '';

  postInstall = ''
    cp META $out/lib/ocaml/${ocaml.version}/site-lib/cairo/
  '';

  createFindlibDestdir = true;
  name = "ocaml${ocaml.version}-${finalAttrs.pname}-${finalAttrs.version}";

  meta = {
    inherit (ocaml.meta) platforms;
    description = "Ocaml bindings for cairo library";
    homepage = "http://cairographics.org/cairo-ocaml";
    license = lib.licenses.gpl2;
    broken = lib.versionAtLeast ocaml.version "4.06";
  };
})

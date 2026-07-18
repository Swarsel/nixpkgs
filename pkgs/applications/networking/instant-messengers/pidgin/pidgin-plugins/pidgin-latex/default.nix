{
  lib,
  stdenv,
  fetchurl,
  glib,
  gtk2,
  imagemagick,
  pidgin,
  pkg-config,
  texLive,
}:

let
  version = "1.5.0";
in
stdenv.mkDerivation {
  inherit version;
  pname = "pidgin-latex";

  src = fetchurl {
    url = "mirror://sourceforge/pidgin-latex/pidgin-latex_${version}.tar.bz2";
    sha256 = "9c850aee90d7e59de834f83e09fa6e3e51b123f06e265ead70957608ada95441";
  };

  postPatch = ''
    sed -e 's/-Wl,-soname//' -i Makefile
  '';

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    gtk2
    glib
    pidgin
  ];

  makeFlags = [ "PREFIX=$(out)" ];

  passthru = {
    wrapArgs = "--prefix PATH ':' ${
      lib.makeBinPath [
        texLive
        imagemagick
      ]
    }";
  };

  meta = {
    description = "LaTeX rendering plugin for Pidgin IM";
    homepage = "https://sourceforge.net/projects/pidgin-latex/";
    license = lib.licenses.gpl2;
    maintainers = [ ];
    platforms = lib.platforms.linux;
  };
}

{
  lib,
  stdenv,
  fetchurl,
  emacs,
  ghostscript,
  texliveBasic,
}:

stdenv.mkDerivation rec {
  pname = "auctex";
  version = "13.2";

  src = fetchurl {
    url = "mirror://gnu/auctex/auctex-${version}.tar.gz";
    hash = "sha256-Hn5AKrz4RmlOuncZklvwlcI+8zpeZgIgHHS2ymCUQDU=";
  };

  outputs = [
    "out"
    "tex"
  ];

  buildInputs = [
    emacs
    ghostscript
    (texliveBasic.withPackages (ps: [
      ps.etoolbox
      ps.hypdoc
    ]))
  ];

  configureFlags = [
    "--with-lispdir=\${out}/share/emacs/site-lisp"
    "--with-texmf-dir=\${tex}"
  ];

  preConfigure = ''
    mkdir -p "$tex"
    export HOME=$(mktemp -d)
  '';

  meta = {
    description = "Extensible package for writing and formatting TeX files in GNU Emacs and XEmacs";
    homepage = "https://www.gnu.org/software/auctex";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.unix;
  };
}

{
  lib,
  stdenv,
  fetchurl,
  fetchFromGitHub,
  tie,
}:

let
  cweb = fetchurl {
    sha256 = "1hdzxfzaibnjxjzgp6d2zay8nsarnfy9hfq55hz1bxzzl23n35aj";
    url = "https://www.ctan.org/tex-archive/web/c_cpp/cweb/cweb-3.64ah.tgz";
  };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "cwebbin";
  version = "22p";

  src = fetchFromGitHub {
    owner = "ascherer";
    repo = "cwebbin";
    rev = "2016-05-20-22p";
    sha256 = "0zf93016hm9i74i2v384rwzcw16y3hg5vc2mibzkx1rzvqa50yfr";
  };

  # Remove references to __DATE__ and __TIME__
  postPatch = ''
    substituteInPlace wmerg-patch.ch --replace ' ("__DATE__", "__TIME__")' ""
    substituteInPlace ctang-patch.ch --replace ' ("__DATE__", "__TIME__")' ""
    substituteInPlace ctangle.cxx --replace ' ("__DATE__", "__TIME__")' ""
    substituteInPlace cweav-patch.ch --replace ' ("__DATE__", "__TIME__")' ""
  '';

  nativeBuildInputs = [ tie ];

  makeFlags = [
    "MACROSDIR=$(out)/share/texmf/tex/generic/cweb"
    "CWEBINPUTS=$(out)/lib/cweb"
    "DESTDIR=$(out)/bin/"
    "MANDIR=$(out)/share/man/man1"
    "EMACSDIR=$(out)/share/emacs/site-lisp"
    "CP=cp"
    "RM=rm"
    "PDFTEX=echo"
    # requires __structuredAttrs = true
    "CC=$(CXX) -std=c++14"
  ];

  buildFlags = [
    "boot"
    "cautiously"
  ];

  preInstall = ''
    mkdir -p $out/share/man/man1 $out/share/texmf/tex/generic $out/share/emacs $out/lib
  '';

  __structuredAttrs = true;
  makefile = "Makefile.unix";

  prePatch = ''
    tar xf ${cweb}
  '';

  meta = {
    inherit (finalAttrs.src.meta) homepage;
    description = "Literate Programming in C/C++";
    license = lib.licenses.abstyles;
    maintainers = [ ];
    platforms = with lib.platforms; unix;
  };
})

{
  lib,
  stdenv,
  fetchurl,
  tcl,
  tk,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "tkrev";
  version = "9.6.1";

  src = fetchurl {
    url = "mirror://sourceforge/tkcvs/tkrev_${finalAttrs.version}.tar.gz";
    sha256 = "sha256-hWGxxL7ArWPi1uCeigJIccke5vYTLn2OWHR7t8TIrZc=";
  };

  buildInputs = [
    tcl
    tk
  ];

  installPhase = ''
    ./doinstall.tcl $out
  '';

  patchPhase = ''
    for file in tkrev/tkrev.tcl tkdiff/tkdiff; do
        substituteInPlace "$file" \
            --replace "exec wish" "exec ${tk}/bin/wish"
    done
  '';

  meta = {
    description = "TCL/TK GUI for cvs and subversion";
    homepage = "https://tkcvs.sourceforge.io";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.unix;
  };
})

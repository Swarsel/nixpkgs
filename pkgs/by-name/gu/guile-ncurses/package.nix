{
  lib,
  stdenv,
  fetchurl,
  guile,
  libffi,
  ncurses5,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "guile-ncurses";
  version = "3.1";

  src = fetchurl {
    url = "mirror://gnu/${finalAttrs.pname}/${finalAttrs.pname}-${finalAttrs.version}.tar.gz";
    hash = "sha256-7onozq/Kud0O8/wazJsQ9NIbpLJW0ynYQtYYPmP41zM=";
  };

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    guile
    libffi
    ncurses5
  ];

  configureFlags = [
    "--with-gnu-filesystem-hierarchy"
  ];

  env = lib.optionalAttrs stdenv.cc.isClang {
    NIX_CFLAGS_COMPILE = "-Wno-error=implicit-function-declaration";
  };

  doCheck = true;

  postFixup = ''
    for f in $out/${guile.siteDir}/ncurses/**.scm; do \
      substituteInPlace $f \
        --replace-fail "libguile-ncurses" "$out/lib/guile/${guile.effectiveVersion}/libguile-ncurses"; \
    done
  '';

  meta = {
    description = "Scheme interface to the NCurses libraries";

    longDescription = ''
      GNU Guile-Ncurses is a library for the Guile Scheme interpreter that
      provides functions for creating text user interfaces.  The text user
      interface functionality is built on the ncurses libraries: curses, form,
      panel, and menu.
    '';

    homepage = "https://www.gnu.org/software/guile-ncurses/";
    license = lib.licenses.lgpl3Plus;
    maintainers = [ ];
    platforms = guile.meta.platforms;
    mainProgram = "guile-ncurses-shell";
  };
})

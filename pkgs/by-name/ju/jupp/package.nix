{
  lib,
  stdenv,
  fetchurl,
  gpm,
  ncurses,
}:

stdenv.mkDerivation rec {
  pname = "jupp";
  version = "41";

  src = fetchurl {
    hash = "sha256-e7jqivUZvv7/+T7DyeMhCNfyuDIWybx7Aa71CYhhyC8=";

    urls = [
      "https://www.mirbsd.org/MirOS/dist/jupp/${srcName}.tgz"
      "https://mbsd.evolvis.org/MirOS/dist/jupp/${srcName}.tgz"
    ];
  };

  buildInputs = [
    gpm
    ncurses
  ];

  configureFlags = [
    "--enable-curses"
    "--enable-getpwnam"
    "--enable-largefile"
    "--enable-termcap"
    "--enable-termidx"
  ];

  env.NIX_CFLAGS_COMPILE = "-std=gnu17";
  preConfigure = "chmod +x ./configure";
  srcName = "joe-3.1${pname}${version}";

  meta = {
    description = "Portable fork of Joe's editor";

    longDescription = ''
      This is the portable version of JOE's Own Editor, which is currently
      developed at sourceforge, licenced under the GNU General Public License,
      Version 1, using autoconf/automake. This version has been enhanced by
      several functions intended for programmers or other professional users,
      and has a lot of bugs fixed. It is based upon an older version of joe
      because these behave better overall.
    '';

    homepage = "http://www.mirbsd.org/jupp.htm";
    license = lib.licenses.gpl1Only;
    maintainers = [ ];
    platforms = with lib.platforms; unix;
    downloadPage = "https://www.mirbsd.org/MirOS/dist/jupp/";
  };
}

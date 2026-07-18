{
  lib,
  stdenv,
  fetchzip,
  which,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "empty";
  version = "0.6.21b";

  src = fetchzip {
    url = "mirror://sourceforge/empty/empty/empty-${finalAttrs.version}.tgz";
    sha256 = "1rkixh2byr70pdxrwr4lj1ckh191rjny1m5xbjsa7nqw1fw6c2xs";
    stripRoot = false;
  };

  patches = [
    ./0.6-Makefile.patch
  ];

  postPatch = ''
    rm empty
  '';

  nativeBuildInputs = [ which ];
  makeFlags = [ "PREFIX=$(out)" ];

  meta = {
    description = "Simple tool to automate interactive terminal applications";

    longDescription = ''
      The empty utility provides an interface to execute and/or interact with
      processes under pseudo-terminal sessions (PTYs). This tool is definitely
      useful in programming of shell scripts designed to communicate with
      interactive programs like telnet, ssh, ftp, etc. In some cases empty can
      be the simplest replacement for TCL/expect or other similar programming
      tools because empty:

      - can be easily invoked directly from shell prompt or script
      - does not use TCL, Perl, PHP, Python or anything else as an underlying language
      - is written entirely in C
      - has small and simple source code
      - can easily be ported to almost all UNIX-like systems
    '';

    homepage = "https://empty.sourceforge.net";
    license = lib.licenses.bsd3;
    maintainers = [ lib.maintainers.djwf ];
    platforms = lib.platforms.all;
    mainProgram = "empty";
  };
})

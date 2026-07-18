{
  lib,
  stdenv,
  buildPackages,
  # apparmor deps
  libapparmor,
  # testing
  perl,
  pkg-config,
  which,
}:
stdenv.mkDerivation {
  inherit (libapparmor)
    version
    src
    ;

  pname = "apparmor-bin-utils";
  strictDeps = true;

  nativeBuildInputs = [
    pkg-config
    libapparmor
    perl
    which
  ];

  buildInputs = [
    libapparmor
  ];

  makeFlags = [
    "LANGS="
    "USE_SYSTEM=1"
    "POD2MAN=${lib.getExe' buildPackages.perl "pod2man"}"
    "POD2HTML=${lib.getExe' buildPackages.perl "pod2html"}"
    "MANDIR=share/man"
  ];

  doCheck = true;
  checkInputs = [ perl ];

  installFlags = [
    "DESTDIR=$(out)"
    "BINDIR=$(out)/bin"
    "SBINDIR=$(out)/bin"
  ];

  sourceRoot = "${libapparmor.src.name}/binutils";

  meta = libapparmor.meta // {
    description = "Mandatory access control system - binary user-land utilities";
  };
}

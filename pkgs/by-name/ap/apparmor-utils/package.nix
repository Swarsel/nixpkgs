{
  lib,
  stdenv,
  # apparmor deps
  apparmor-parser,
  buildPackages,
  gawk,
  makeWrapper,
  perl,
  python3Packages,
  runtimeShellPackage,
  which,
  linuxHeaders ? stdenv.cc.libc.linuxHeaders,
}:
let
  inherit (python3Packages) libapparmor;
in
python3Packages.buildPythonApplication {
  inherit (libapparmor) version src;
  pname = "apparmor-utils";

  postPatch = ''
    patchShebangs common
    cd utils

    substituteInPlace aa-remove-unknown \
      --replace-fail "/lib/apparmor/rc.apparmor.functions" "${apparmor-parser}/lib/apparmor/rc.apparmor.functions"
    substituteInPlace Makefile \
      --replace-fail "/usr/include/linux/capability.h" "${linuxHeaders}/include/linux/capability.h"
    sed -i -E 's/^(DESTDIR|BINDIR|PYPREFIX)=.*//g' Makefile
    sed -i aa-unconfined -e "/my_env\['PATH'\]/d"
  ''
  + (lib.optionalString stdenv.hostPlatform.isMusl ''
    sed -i Makefile -e "/\<vim\>/d"
  '');

  strictDeps = true;

  nativeBuildInputs = [
    makeWrapper
    which
    python3Packages.setuptools
  ];

  buildInputs = [
    perl
    runtimeShellPackage
  ];

  makeFlags = [
    "LANGS="
    "POD2MAN=${lib.getExe' buildPackages.perl "pod2man"}"
    "POD2HTML=${lib.getExe' buildPackages.perl "pod2html"}"
    "MANDIR=share/man"
  ];

  doCheck = true;

  postInstall = ''
    wrapProgram $out/bin/aa-remove-unknown \
     --prefix PATH : ${lib.makeBinPath [ gawk ]}
  '';

  installFlags = [
    "DESTDIR=$(out)"
    "BINDIR=$(out)/bin"
    "VIM_INSTALL_PATH=$(out)/share"
    "PYPREFIX="
  ];

  pyproject = false;

  pythonPath = [
    python3Packages.notify2
    python3Packages.psutil
    libapparmor
  ];

  meta = libapparmor.meta // {
    description = "Mandatory access control system - script user-land utilities";
  };
}

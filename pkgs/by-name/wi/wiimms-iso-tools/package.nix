{
  lib,
  stdenv,
  fetchurl,
  fetchpatch,
  fuse3,
  ncurses,
  versionCheckHook,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "wiimms-iso-tools";
  version = "3.05a";

  src = fetchurl {
    url = "https://download.wiimm.de/source/wiimms-iso-tools/wiimms-iso-tools.source-${finalAttrs.version}.txz";
    hash = "sha256-5aikiPJkZf9OwD8QmQ7ijhBOtFQpkIErvb6gOvEu2L0=";
  };

  patches = [
    ./fix-paths.diff

    # Pull pending upstream fix for ncurses-6.3:
    #  https://github.com/Wiimm/wiimms-iso-tools/pull/14
    (fetchpatch {
      name = "ncurses-6.3.patch";
      sha256 = "18cfri4y1082phg6fzh402gk5ri24wr8ff4zl8v5rlgjndh610im";
      stripLen = 1;
      url = "https://github.com/Wiimm/wiimms-iso-tools/commit/3f1e84ec6915cc4f658092d33411985bd3eaf4e6.patch";
    })
  ];

  postPatch = ''
    patchShebangs setup.sh gen-template.sh gen-text-file.sh
    substituteInPlace setup.sh --replace gcc "$CC"
    substituteInPlace Makefile --replace gcc "$CC"
  '';

  buildInputs = [
    zlib
    ncurses
    fuse3
  ];

  env.INSTALL_PATH = "$out";

  installPhase = ''
    mkdir "$out"
    patchShebangs install.sh
    ./install.sh --no-sudo
  '';

  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  versionCheckProgram = "${placeholder "out"}/bin/wit";

  meta = {
    description = "Set of command line tools to manipulate Wii and GameCube ISO images and WBFS containers";
    homepage = "https://wit.wiimm.de";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ nilp0inter ];
    platforms = lib.platforms.unix;
  };
})

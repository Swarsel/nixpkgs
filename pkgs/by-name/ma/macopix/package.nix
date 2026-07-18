{
  lib,
  stdenv,
  fetchurl,
  gtk3,
  openssl,
  pkg-config,
  versionCheckHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "macopix";
  version = "3.4.0";

  # GitHub does not contain tags
  # https://github.com/chimari/MaCoPiX/issues/6
  src = fetchurl {
    url = "https://rosegray.sakura.ne.jp/macopix/macopix-${finalAttrs.version}.tar.gz";
    hash = "sha256-1AjqdPPCc9UQWqLdWlA+Va+MmvKL8dAIfJURPifN7RI=";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    gtk3
    openssl
  ];

  env = {
    # Workaround build failure on -fno-common toolchains:
    #   ld: dnd.o:src/main.h:136: multiple definition of
    #     `MENU_EXT'; main.o:src/main.h:136: first defined here
    NIX_CFLAGS_COMPILE = "-fcommon -std=gnu99";
    NIX_LDFLAGS = "-lX11";
  };

  preConfigure = ''
    # Build fails on Linux with windres.
    export ac_cv_prog_WINDRES=
  '';

  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  enableParallelBuilding = true;

  meta = {
    description = "Mascot Constructive Pilot for X";
    homepage = "http://rosegray.sakura.ne.jp/macopix/index-e.html";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.linux;
    mainProgram = "macopix";
  };
})

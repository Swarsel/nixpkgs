{
  lib,
  stdenv,
  kernel,
  ncurses,
}:

stdenv.mkDerivation {
  inherit (kernel) src;
  pname = "tmon";
  version = kernel.version;
  buildInputs = [ ncurses ];

  makeFlags = [
    "ARCH=${stdenv.hostPlatform.linuxArch}"
    "CROSS_COMPILE=${stdenv.cc.targetPrefix}"
    "INSTALL_ROOT=\"$(out)\""
    "BINDIR=bin"
  ];

  env.NIX_CFLAGS_LINK = "-lgcc_s";

  configurePhase = ''
    cd tools/thermal/tmon
  '';

  enableParallelBuilding = true;

  meta = {
    description = "Monitoring and Testing Tool for Linux kernel thermal subsystem";
    homepage = "https://www.kernel.org/";
    license = lib.licenses.gpl2Only;
    platforms = lib.platforms.linux;
    mainProgram = "tmon";
  };
}

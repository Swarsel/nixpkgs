{
  lib,
  stdenv,
  fetchurl,
  buildPackages,
  elfutils,
  gitUpdater,
  libunwind,
  perl,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "strace";
  version = "7.1";

  src = fetchurl {
    url = "https://strace.io/files/${finalAttrs.version}/strace-${finalAttrs.version}.tar.xz";
    hash = "sha256-gXQ+zypbRBhrL1A4r9yL7aflxwrtFbT7+8xuns4kSQ8=";
  };

  outputs = [
    "out"
    "man"
  ];

  nativeBuildInputs = [ perl ];

  # libunwind for -k.
  # On RISC-V platforms, LLVM's libunwind implementation is unsupported by strace.
  # The build will silently fall back and -k will not work on RISC-V.
  buildInputs = [
    libunwind
  ]
  # -kk
  ++ lib.optional (lib.meta.availableOn stdenv.hostPlatform elfutils) elfutils;

  configureFlags = [
    "--enable-mpers=check"
  ]
  ++ lib.optional stdenv.cc.isClang "CFLAGS=-Wno-unused-function";

  depsBuildBuild = [ buildPackages.stdenv.cc ];
  enableParallelBuilding = true;
  separateDebugInfo = true;

  passthru.updateScript = gitUpdater {
    rev-prefix = "v";
    # No nicer place to find latest release.
    url = "https://github.com/strace/strace.git";
  };

  meta = {
    description = "System call tracer for Linux";
    homepage = "https://strace.io/";

    license = with lib.licenses; [
      lgpl21Plus
      gpl2Plus
    ]; # gpl2Plus is for the test suite

    maintainers = with lib.maintainers; [
      globin
      ma27
      qyliss
    ];

    platforms = lib.platforms.linux;
    mainProgram = "strace";
  };
})

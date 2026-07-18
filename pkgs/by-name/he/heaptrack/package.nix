{
  lib,
  stdenv,
  fetchFromGitLab,
  boost,
  cmake,
  elfutils,
  kdePackages,
  libunwind,
  makeBinaryWrapper,
  rustc-demangle,
  sparsehash,
  zlib,
  zstd,
}:

stdenv.mkDerivation {
  pname = "heaptrack";
  version = "1.5.0-unstable-2025-07-21";

  src = fetchFromGitLab {
    owner = "sdk";
    repo = "heaptrack";
    rev = "9db5d53df554959478575e080648f6854d362faf";
    hash = "sha256-8NLpp/+PK3wIB5Sx0Z1185DCDQ18zsGj9Wp5YNKgX8E=";
    domain = "invent.kde.org";
  };

  patches = [
    ./boost-189.patch
    ./cmake-minimum-required.patch
  ];

  postPatch = ''
    substituteInPlace src/interpret/demangler.cpp \
      --replace-fail "librustc_demangle.so" "${rustc-demangle}/lib/librustc_demangle.so"
  '';

  nativeBuildInputs = [
    cmake
    kdePackages.extra-cmake-modules
    makeBinaryWrapper
    kdePackages.wrapQtAppsHook
  ];

  buildInputs = [
    zlib
    boost
    libunwind
    sparsehash
    zstd
    rustc-demangle
  ]
  ++ (with kdePackages; [
    qtbase
    kio
    kitemmodels
    threadweaver
    kconfigwidgets
    kcoreaddons
    kdiagram
  ])

  ++ lib.optionals stdenv.hostPlatform.isLinux [
    elfutils
  ];

  postInstall = lib.optionalString stdenv.hostPlatform.isDarwin ''
    makeWrapper \
      $out/Applications/KDE/heaptrack_gui.app/Contents/MacOS/heaptrack_gui \
      $out/bin/heaptrack_gui
  '';

  meta = {
    description = "Heap memory profiler for Linux";
    homepage = "https://github.com/KDE/heaptrack";
    license = lib.licenses.lgpl21Plus;
    maintainers = [ ];
    platforms = lib.platforms.unix;
    mainProgram = "heaptrack_gui";
  };
}

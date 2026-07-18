{
  lib,
  stdenv,
  fetchFromGitHub,
  at-spi2-core,
  cmake,
  dbus,
  glfw,
  gtk3,
  gtkmm3,
  libcpuid,
  libdatrie,
  libepoxy,
  libselinux,
  libsepol,
  libthai,
  libxdmcp,
  libxkbcommon,
  libxtst,
  nasm,
  ncurses,
  ocl-icd,
  opencl-headers,
  pciutils,
  pkg-config,
  procps,
  testers,
  util-linux,
  vulkan-headers,
  vulkan-loader,
  wrapGAppsHook3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "cpu-x";
  version = "5.4.0";

  src = fetchFromGitHub {
    owner = "TheTumultuousUnicornOfDarkness";
    repo = "CPU-X";
    tag = "v${finalAttrs.version}";
    hash = "sha256-db7NxoVZgnYb1MZKfiFINx00JqDnf/TvwumBp6qDooQ=";
  };

  postPatch = ''
    # https://github.com/TheTumultuousUnicornOfDarkness/CPU-X/pull/402
    # FIXME: remove in the next version
    substituteInPlace src/core/bandwidth/{OOC/utility,routines}-x86-64bit.asm \
      --replace-fail "cpu	ia64" "cpu	default"
  '';

  nativeBuildInputs = [
    cmake
    pkg-config
    wrapGAppsHook3
    nasm
  ];

  buildInputs = [
    gtk3
    gtkmm3
    ncurses
    libcpuid
    pciutils
    procps
    vulkan-headers
    vulkan-loader
    glfw
    opencl-headers
    ocl-icd
    libxdmcp
    util-linux
    libselinux
    libsepol
    libthai
    libdatrie
    libxkbcommon
    libepoxy
    dbus
    at-spi2-core
    libxtst
  ];

  preFixup = ''
    gappsWrapperArgs+=(
      --prefix PATH : ${lib.makeBinPath [ stdenv.cc ]}
      --prefix LD_LIBRARY_PATH : ${vulkan-loader}/lib
    )
  '';

  passthru = {
    tests = {
      version = testers.testVersion { package = finalAttrs.finalPackage; };
    };
  };

  meta = {
    description = "Free software that gathers information on CPU, motherboard and more";
    homepage = "https://thetumultuousunicornofdarkness.github.io/CPU-X";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ viraptor ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "cpu-x";
  };
})

{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  curl,
  doxygen,
  git,
  help2man,
  libusb1,
  ncurses,
  pkg-config,
  tecla,
  udev,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libbladeRF";
  version = "2025.10";

  src = fetchFromGitHub {
    owner = "Nuand";
    repo = "bladeRF";
    tag = finalAttrs.version;
    hash = "sha256-gp+OnAlECGZs4+JEWNX5Gt7LYdTFJUItpmDdJgeoJO4=";
    fetchSubmodules = true;
  };

  patches = [
    # fix clang build: https://github.com/Nuand/bladeRF/pull/1045
    ./clang-fix.patch
  ];

  # Let us avoid net-tools as a dependency.
  postPatch = ''
    sed -i 's/$(hostname)/hostname/' host/utilities/bladeRF-cli/src/cmd/doc/generate.bash
  '';

  nativeBuildInputs = [
    cmake
    pkg-config
    git
    doxygen
    help2man
  ];

  # ncurses used due to https://github.com/Nuand/bladeRF/blob/ab4fc672c8bab4f8be34e8917d3f241b1d52d0b8/host/utilities/bladeRF-cli/CMakeLists.txt#L208
  buildInputs = [
    tecla
    libusb1
    curl
    ncurses
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [ udev ];

  cmakeFlags = [
    "-DBUILD_DOCUMENTATION=ON"
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    "-DUDEV_RULES_PATH=etc/udev/rules.d"
    "-DINSTALL_UDEV_RULES=ON"
    "-DBLADERF_GROUP=bladerf"
  ];

  env = lib.optionalAttrs stdenv.cc.isClang {
    NIX_CFLAGS_COMPILE = "-Wno-error=unused-but-set-variable -Wno-error=tautological-overlap-compare";
  };

  doInstallCheck = true;
  hardeningDisable = [ "fortify" ];
  # Fixup shebang
  prePatch = "patchShebangs host/utilities/bladeRF-cli/src/cmd/doc/generate.bash";

  meta = {
    description = "Supporting library of the BladeRF SDR opensource hardware";
    homepage = "https://nuand.com/libbladeRF-doc";
    license = lib.licenses.lgpl21;
    maintainers = with lib.maintainers; [ markuskowa ];
    platforms = lib.platforms.unix;
  };
})

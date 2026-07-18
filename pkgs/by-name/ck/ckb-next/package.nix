{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  gnused,
  kmod,
  libpulseaudio,
  libxdmcp,
  pkg-config,
  qt6,
  qt6Packages,
  replaceVars,
  udev,
  udevCheckHook,
  wayland-protocols,
  zlib,
  withPulseaudio ? stdenv.hostPlatform.isLinux,
}:

stdenv.mkDerivation {
  pname = "ckb-next";
  version = "0.6.2-unstable-2025-09-25";

  src = fetchFromGitHub {
    owner = "ckb-next";
    repo = "ckb-next";
    rev = "4bf942dba5e73c2778ef797b6b8dd6b0239aca9a";
    hash = "sha256-sKgA1LZXZ64OixhbBWYUyCN4y29DRG0O0b/bAMd1I8M=";
  };

  patches = [
    ./install-dirs.patch
    (replaceVars ./modprobe.patch {
      inherit kmod;
    })
  ];

  nativeBuildInputs = [
    qt6.wrapQtAppsHook
    pkg-config
    cmake
    udevCheckHook
  ];

  buildInputs = [
    udev
    qt6.qtbase
    zlib
    libxdmcp
    qt6.qttools
    qt6Packages.quazip
    qt6.qtwayland
    wayland-protocols
  ]
  ++ lib.optional withPulseaudio libpulseaudio;

  cmakeFlags = [
    "-DINSTALL_DIR_ANIMATIONS=libexec"
    "-DUDEV_RULE_DIRECTORY=lib/udev/rules.d"
    "-DFORCE_INIT_SYSTEM=systemd"
    "-DDISABLE_UPDATER=1"
  ];

  postInstall = ''
    substituteInPlace "$out/lib/udev/rules.d/99-ckb-next-daemon.rules" \
      --replace-fail "/usr/bin/env sed" "${lib.getExe gnused}"
  '';

  doInstallCheck = true;

  meta = {
    description = "Driver and configuration tool for Corsair keyboards and mice";
    homepage = "https://github.com/ckb-next/ckb-next";
    license = lib.licenses.gpl2Only;
    maintainers = [ ];
    platforms = lib.platforms.linux;
    mainProgram = "ckb-next";
  };
}

{
  lib,
  fetchFromGitHub,
  autoreconfHook,
  avahi,
  clang,
  clangStdenv,
  git,
  libgeneral,
  libimobiledevice,
  libusb1,
  pkg-config,
}:
clangStdenv.mkDerivation {
  pname = "usbmuxd2";
  version = "unstable-2023-12-12";

  src = fetchFromGitHub {
    owner = "tihmstar";
    repo = "usbmuxd2";
    rev = "2ce399ddbacb110bd5a83a6b8232d42c9a9b6e84";
    hash = "sha256-u7qRKH5y+Q1HnnumjVm3Ce4SlT3YaEVSPUXYOAiFBes=";
    # Leave DotGit so that autoconfigure can read version from git tags
    leaveDotGit = true;
  };

  postPatch = ''
    # Checking for libgeneral version still fails
    sed -i 's/libgeneral >= $LIBGENERAL_MINVERS_STR/libgeneral/' configure.ac

    # Otherwise, it will complain about no matching function for call to 'find'
    sed -i 1i'#include <algorithm>' usbmuxd2/Muxer.cpp
  '';

  nativeBuildInputs = [
    autoreconfHook
    clang
    git
    pkg-config
  ];

  propagatedBuildInputs = [
    avahi
    libgeneral
    libimobiledevice
    libusb1
  ];

  configureFlags = [
    "--with-udevrulesdir=${placeholder "out"}/lib/udev/rules.d"
    "--with-systemdsystemunitdir=${placeholder "out"}/lib/systemd/system"
  ];

  makeFlags = [
    "sbindir=${placeholder "out"}/bin"
  ];

  doInstallCheck = true;

  meta = {
    description = "Socket daemon to multiplex connections from and to iOS devices";
    homepage = "https://github.com/tihmstar/usbmuxd2";
    license = lib.licenses.lgpl3;
    maintainers = with lib.maintainers; [ onny ];
    platforms = lib.platforms.linux;
    mainProgram = "usbmuxd";
  };
}

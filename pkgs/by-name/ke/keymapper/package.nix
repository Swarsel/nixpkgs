{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  dbus,
  gtk3,
  libayatana-appindicator,
  libusb1,
  libx11,
  libxkbcommon,
  pkg-config,
  udev,
  wayland,
  wayland-scanner,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "keymapper";
  version = "5.3.1";

  src = fetchFromGitHub {
    owner = "houmain";
    repo = "keymapper";
    tag = finalAttrs.version;
    hash = "sha256-YKfKgsrjDrskLEoYCSRMYco7+7E/sgXFAMEwwm7rs7w=";
  };

  # all the following must be in nativeBuildInputs
  nativeBuildInputs = [
    cmake
    pkg-config
    dbus
    wayland
    wayland-scanner
    libx11
    udev
    libusb1
    libxkbcommon
    gtk3
    libayatana-appindicator
  ];

  meta = {
    description = "Cross-platform context-aware key remapper";
    homepage = "https://github.com/houmain/keymapper";
    changelog = "https://github.com/houmain/keymapper/blob/${finalAttrs.src.rev}/CHANGELOG.md";
    license = lib.licenses.gpl3Only;

    maintainers = [
    ];

    platforms = lib.platforms.linux;
    mainProgram = "keymapper";
  };
})

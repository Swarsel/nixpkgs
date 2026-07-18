{
  lib,
  stdenv,
  fetchFromGitHub,
  libGL,
  libx11,
  libxcb-wm,
  libxkbcommon,
  makeWrapper,
  meson,
  ninja,
  nixosTests,
  pixman,
  pkg-config,
  scdoc,
  wayland,
  wayland-protocols,
  wayland-scanner,
  wlroots_0_20,
  xwayland ? null,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "cage";
  version = "0.3.1";

  src = fetchFromGitHub {
    owner = "cage-kiosk";
    repo = "cage";
    tag = "v${finalAttrs.version}";
    hash = "sha256-FHIOicRBL881Kvvui4HTKy0g7K9HcQ0ineLECh6MqFI=";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    wayland-scanner
    scdoc
    makeWrapper
  ];

  buildInputs = [
    wlroots_0_20
    wayland
    wayland-protocols
    pixman
    libxkbcommon
    libxcb-wm
    libGL
    libx11
  ];

  postFixup = lib.optionalString wlroots_0_20.enableXWayland ''
    wrapProgram $out/bin/cage --prefix PATH : "${xwayland}/bin"
  '';

  depsBuildBuild = [
    pkg-config
  ];

  # Tests Cage using the NixOS module by launching xterm:
  passthru.tests.basic-nixos-module-functionality = nixosTests.cage;

  meta = {
    description = "Wayland kiosk that runs a single, maximized application";
    homepage = "https://www.hjdskes.nl/projects/cage/";
    license = lib.licenses.mit;
    maintainers = [ ];
    platforms = lib.platforms.linux;
    mainProgram = "cage";
  };
})

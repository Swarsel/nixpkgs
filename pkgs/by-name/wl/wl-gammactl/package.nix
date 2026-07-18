{
  lib,
  stdenv,
  fetchFromGitHub,
  glib,
  gtk3,
  meson,
  ninja,
  pkg-config,
  wayland,
  wayland-scanner,
  wlr-protocols,
}:

stdenv.mkDerivation {
  pname = "wl-gammactl";
  version = "0-unstable-2021-09-13";

  src = fetchFromGitHub {
    owner = "mischw";
    repo = "wl-gammactl";
    rev = "e2385950d97a3baf1b6e2f064dd419ccec179586";
    sha256 = "8iMJK4O/sNIGPOBZQEfK47K6OjT6sxYFe19O2r/VSr8=";
  };

  patches = [ ./dont-need-wlroots.diff ];

  postPatch = ''
    substituteInPlace meson.build --replace "git = find_program('git')" "git = 'false'"
  '';

  strictDeps = true;

  nativeBuildInputs = [
    meson
    pkg-config
    ninja
    glib
    wayland-scanner
  ];

  buildInputs = [
    wayland
    gtk3
  ];

  postUnpack = ''
    rmdir source/wlr-protocols
    ln -s ${wlr-protocols}/share/wlr-protocols source
  '';

  meta = {
    description = "Contrast, brightness, and gamma adjustments for Wayland";

    longDescription = ''
      Small GTK GUI application to set contrast, brightness, and gamma for wayland compositors which
      support the wlr-gamma-control protocol extension.
    '';

    homepage = "https://github.com/mischw/wl-gammactl";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ lodi ];
    platforms = lib.platforms.linux;
    mainProgram = "wl-gammactl";
  };
}

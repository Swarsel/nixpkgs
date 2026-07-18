{
  lib,
  stdenv,
  fetchFromGitHub,
  brightnessctl,
  dbus,
  dbus-glib,
  gdk-pixbuf,
  glib,
  gobject-introspection,
  gtk-layer-shell,
  gtk3,
  librsvg,
  meson,
  ninja,
  pamixer,
  pkg-config,
  vala,
  wrapGAppsHook3,
}:

stdenv.mkDerivation {
  pname = "avizo";
  version = "1.3-unstable-2024-11-03";

  src = fetchFromGitHub {
    owner = "heyjuvi";
    repo = "avizo";
    rev = "5efaa22968b2cc1a3c15a304cac3f22ec2727b17";
    sha256 = "sha256-KYQPHVxjvqKt4d7BabplnrXP30FuBQ6jQ1NxzR5U7qI=";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    vala
    gobject-introspection
    wrapGAppsHook3
  ];

  buildInputs = [
    dbus
    dbus-glib
    gdk-pixbuf
    glib
    gtk-layer-shell
    gtk3
    librsvg
  ];

  postInstall = ''
    wrapProgram $out/bin/volumectl --suffix PATH : $out/bin:${lib.makeBinPath [ pamixer ]}
    wrapProgram $out/bin/lightctl --suffix PATH : $out/bin:${lib.makeBinPath [ brightnessctl ]}
  '';

  meta = {
    description = "Neat notification daemon for Wayland";
    homepage = "https://github.com/heyjuvi/avizo";
    license = lib.licenses.gpl3;

    maintainers = [
      lib.maintainers.berbiche
      lib.maintainers.flexiondotorg
    ];

    platforms = lib.platforms.linux;
  };
}

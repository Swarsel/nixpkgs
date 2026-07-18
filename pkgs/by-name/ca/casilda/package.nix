{
  lib,
  stdenv,
  fetchFromGitLab,
  glib,
  gobject-introspection,
  gtk4,
  libepoxy,
  libxkbcommon,
  meson,
  ninja,
  pkg-config,
  wayland,
  wayland-protocols,
  wayland-scanner,
  wlroots_0_20,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "casilda";
  version = "1.2.2";

  src = fetchFromGitLab {
    owner = "jpu";
    repo = "casilda";
    tag = finalAttrs.version;
    hash = "sha256-JMDS+fx0vUZnfNz5bzmTy8/4BkgMypWBp+qjorTVmK4=";
    domain = "gitlab.gnome.org";
  };

  outputs = [
    "out"
    "dev"
  ];

  strictDeps = true;

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    gobject-introspection
    wayland-scanner
  ];

  buildInputs = [
    libepoxy
    glib
    wayland-protocols
    wayland # for wayland-server
    libxkbcommon
    wlroots_0_20
  ];

  propagatedBuildInputs = [ gtk4 ];
  depsBuildBuild = [ pkg-config ];

  meta = {
    description = "Simple Wayland compositor widget for Gtk 4 which can be used to embed other processes windows in Gtk 4 application";
    homepage = "https://gitlab.gnome.org/jpu/casilda";
    license = lib.licenses.lgpl21Plus;
    maintainers = with lib.maintainers; [ clerie ];
    platforms = lib.platforms.unix;
  };
})

{
  lib,
  stdenv,
  fetchurl,
  glib,
  gnome,
  gobject-introspection,
  gtk3,
  libxklavier,
  meson,
  ninja,
  pkg-config,
  wrapGAppsHook3,
}:

stdenv.mkDerivation rec {
  pname = "libgnomekbd";
  version = "3.28.1";

  src = fetchurl {
    url = "mirror://gnome/sources/libgnomekbd/${lib.versions.majorMinor version}/libgnomekbd-${version}.tar.xz";
    sha256 = "ItxZVm1zwAZTUPWpc0DmLsx7CMTfGRg4BLuL4kyP6HA=";
  };

  outputs = [
    "out"
    "dev"
  ];

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    wrapGAppsHook3
    glib
    gobject-introspection
  ];

  # Requires in libgnomekbd.pc
  propagatedBuildInputs = [
    gtk3
    libxklavier
    glib
  ];

  postInstall = ''
    # Missing post-install script.
    glib-compile-schemas "$out/share/glib-2.0/schemas"
  '';

  passthru = {
    updateScript = gnome.updateScript {
      packageName = pname;
      versionPolicy = "odd-unstable";
    };
  };

  meta = {
    description = "Keyboard management library";
    license = lib.licenses.gpl2;
    platforms = lib.platforms.linux;
    mainProgram = "gkbd-keyboard-display";
    teams = [ lib.teams.gnome ];
  };
}

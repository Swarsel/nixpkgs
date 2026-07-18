{
  lib,
  stdenv,
  fetchFromGitHub,
  appstream-glib,
  cairo,
  desktop-file-utils,
  glib,
  goocanvas_3,
  gtk3,
  gtksourceview3,
  json-glib,
  libarchive,
  libgee,
  libxml2,
  meson,
  ninja,
  pantheon,
  pkg-config,
  python3,
  vala,
  wrapGAppsHook3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "akira";
  version = "0.0.16";

  src = fetchFromGitHub {
    owner = "akiraux";
    repo = "Akira";
    tag = "v${finalAttrs.version}";
    sha256 = "sha256-qrqmSCwA0kQVFD1gzutks9gMr7My7nw/KJs/VPisa0w=";
  };

  postPatch = ''
    chmod +x build-aux/meson/post_install.py
    patchShebangs build-aux/meson/post_install.py
  '';

  nativeBuildInputs = [
    appstream-glib
    desktop-file-utils
    meson
    ninja
    pkg-config
    python3
    vala
    wrapGAppsHook3
  ];

  buildInputs = [
    cairo
    glib
    goocanvas_3
    pantheon.granite
    gtk3
    gtksourceview3
    json-glib
    libarchive
    libgee
    libxml2
  ];

  mesonFlags = [ "-Dprofile=default" ];

  meta = {
    description = "Native Linux Design application built in Vala and GTK";
    homepage = "https://github.com/akiraux/Akira";
    license = lib.licenses.gpl3Plus;
    maintainers = [ ];
    platforms = lib.platforms.linux;
    mainProgram = "com.github.akiraux.akira";
    teams = [ lib.teams.pantheon ];
  };
})

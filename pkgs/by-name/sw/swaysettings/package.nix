{
  lib,
  stdenv,
  fetchFromGitHub,
  accountsservice,
  appstream-glib,
  blueprint-compiler,
  dbus,
  desktop-file-utils,
  fetchpatch2,
  gettext,
  glib,
  gobject-introspection,
  gsettings-desktop-schemas,
  gtk-layer-shell,
  gtk3,
  gtk4,
  gtk4-layer-shell,
  json-glib,
  libadwaita,
  libgee,
  libgtop,
  libhandy,
  libpulseaudio,
  libxml2,
  meson,
  ninja,
  pantheon,
  pkg-config,
  python3,
  udisks,
  vala,
  wrapGAppsHook3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "swaysettings";
  version = "0.5.0";

  src = fetchFromGitHub {
    owner = "ErikReider";
    repo = "SwaySettings";
    tag = "v${finalAttrs.version}";
    hash = "sha256-XP0Q3Q40cvAl3MEqShY+VMWjlCtqs9e91nkxocVNQQQ=";
  };

  patches = [
    (fetchpatch2 {
      hash = "sha256-3A0VPAUQ3UjQ2mqR24z5CQ5Tdjw73UzfPz5UUcl/FDA=";
      name = "gtk-4.20-fix.patch";
      url = "https://github.com/ErikReider/SwaySettings/commit/e4f3749a053b5fbe0feab93e46d6eba380ee2e58.patch?full_index=1";
    })
  ];

  postPatch = ''
    patchShebangs build-aux/meson/postinstall.py
  '';

  nativeBuildInputs = [
    appstream-glib
    desktop-file-utils
    gettext
    meson
    ninja
    pkg-config
    python3
    vala
    wrapGAppsHook3
    gobject-introspection
    blueprint-compiler
    udisks
    libgtop
    gtk4-layer-shell
  ];

  buildInputs = [
    accountsservice
    dbus
    glib
    gsettings-desktop-schemas
    gtk-layer-shell
    gtk3
    json-glib
    libgee
    libhandy
    libpulseaudio
    libxml2
    pantheon.granite7
    gtk4
    libadwaita
  ];

  meta = {
    description = "GUI for configuring your sway desktop";

    longDescription = ''
      Sway settings enables easy configuration of a sway desktop environment
      such as selection of application or icon themes.
    '';

    homepage = "https://github.com/ErikReider/SwaySettings";
    license = lib.licenses.gpl3Plus;
    maintainers = [ lib.maintainers.aacebedo ];
    platforms = lib.platforms.linux;
  };
})

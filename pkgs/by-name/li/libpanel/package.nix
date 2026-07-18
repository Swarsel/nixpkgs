{
  lib,
  stdenv,
  fetchurl,
  gi-docgen,
  glib,
  gnome,
  gobject-introspection,
  gtk4,
  libadwaita,
  meson,
  ninja,
  pkg-config,
  vala,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libpanel";
  version = "1.10.4";

  src = fetchurl {
    url = "mirror://gnome/sources/libpanel/${lib.versions.majorMinor finalAttrs.version}/libpanel-${finalAttrs.version}.tar.xz";
    hash = "sha256-WTiIp2kfCviqpuGTyeFK+oaoEMDC8nUVxtgT8Yczsc0=";
  };

  outputs = [
    "out"
    "dev"
    "devdoc"
  ];

  strictDeps = true;

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    gobject-introspection
    vala
    gi-docgen
    gtk4 # gtk4-update-icon-cache
  ];

  buildInputs = [
    glib
    gtk4
    libadwaita
  ];

  mesonFlags = [
    (lib.mesonBool "install-examples" true)
  ];

  postFixup = ''
    # Cannot be in postInstall, otherwise _multioutDocs hook in preFixup will move right back.
    moveToOutput "share/doc" "$devdoc"
  '';

  depsBuildBuild = [ pkg-config ];
  outputBin = "dev";

  passthru = {
    updateScript = gnome.updateScript {
      packageName = "libpanel";
      versionPolicy = "odd-unstable";
    };
  };

  meta = {
    description = "Dock/panel library for GTK 4";
    homepage = "https://gitlab.gnome.org/GNOME/libpanel";
    license = lib.licenses.lgpl3Plus;
    platforms = lib.platforms.unix;
    mainProgram = "libpanel-example";
    teams = [ lib.teams.gnome ];
  };
})

{
  lib,
  stdenv,
  fetchurl,
  enchant,
  gi-docgen,
  glib,
  gnome,
  gobject-introspection,
  gtk4,
  gtksourceview5,
  icu,
  libsysprof-capture,
  meson,
  ninja,
  pkg-config,
  vala,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libspelling";
  version = "0.4.10";

  src = fetchurl {
    url = "mirror://gnome/sources/libspelling/${lib.versions.majorMinor finalAttrs.version}/libspelling-${finalAttrs.version}.tar.xz";
    hash = "sha256-VuPwGjoYtXW+6kw0NJ+ZzaujFuH3wnGxIx97z12a9zs=";
  };

  outputs = [
    "out"
    "dev"
    "devdoc"
  ];

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    gobject-introspection
    vala
    gi-docgen
  ];

  buildInputs = [
    enchant
    icu
    libsysprof-capture
  ];

  propagatedBuildInputs = [
    # These were moved from buildInputs because they are
    # listed in `Requires` key of `libspelling-1.pc`
    glib
    gtk4
    gtksourceview5
  ];

  postFixup = ''
    # Cannot be in postInstall, otherwise _multioutDocs hook in preFixup will move right back.
    moveToOutput "share/doc" "$devdoc"
  '';

  passthru.updateScript = gnome.updateScript {
    packageName = "libspelling";
  };

  meta = {
    description = "Spellcheck library for GTK 4";
    homepage = "https://gitlab.gnome.org/GNOME/libspelling";
    changelog = "https://gitlab.gnome.org/GNOME/libspelling/-/raw/${finalAttrs.version}/NEWS";
    license = lib.licenses.lgpl21Plus;
    maintainers = with lib.maintainers; [ chuangzhu ];
    teams = [ lib.teams.gnome ];
  };
})

{
  lib,
  stdenv,
  fetchurl,
  adwaita-icon-theme,
  blueprint-compiler,
  desktop-file-utils,
  docbook-xsl-nons,
  gdk-pixbuf,
  gettext,
  gexiv2_0_16,
  gi-docgen,
  glib-networking,
  gnome,
  gnome-autoar,
  gnome-desktop,
  gnome-user-share,
  gobject-introspection,
  gsettings-desktop-schemas,
  gst_all_1,
  gtk4,
  icu,
  libadwaita,
  libcloudproviders,
  libexif,
  libglycin,
  libglycin-gtk4,
  libjxl,
  libnotify,
  libportal-gtk4,
  librsvg,
  libseccomp,
  libselinux,
  localsearch,
  meson,
  ninja,
  pkg-config,
  shared-mime-info,
  tinysparql,
  wayland-scanner,
  webp-pixbuf-loader,
  wrapGAppsHook4,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "nautilus";
  version = "50.2.2";

  src = fetchurl {
    url = "mirror://gnome/sources/nautilus/${lib.versions.major finalAttrs.version}/nautilus-${finalAttrs.version}.tar.xz";
    hash = "sha256-4eKF7930LtMN2lsp9/jSQtq0vBQJqQVIY7NnutSzTVo=";
  };

  outputs = [
    "out"
    "dev"
    "devdoc"
  ];

  patches = [
    # Allow changing extension directory using environment variable.
    ./extension_dir.patch
  ];

  nativeBuildInputs = [
    blueprint-compiler
    desktop-file-utils
    gettext
    gobject-introspection
    meson
    ninja
    pkg-config
    gi-docgen
    docbook-xsl-nons
    wayland-scanner
    wrapGAppsHook4
  ];

  buildInputs = [
    gexiv2_0_16
    glib-networking
    icu
    gnome-desktop
    adwaita-icon-theme
    gsettings-desktop-schemas
    gnome-user-share
    gst_all_1.gst-plugins-base
    gtk4
    libadwaita
    libportal-gtk4
    libexif
    libnotify
    libseccomp
    libselinux
    gdk-pixbuf
    libcloudproviders
    shared-mime-info
    tinysparql
    localsearch
    gnome-autoar
    libglycin
    libglycin-gtk4
  ];

  propagatedBuildInputs = [
    gtk4
  ];

  mesonFlags = [
    "-Ddocs=true"
    "-Dtests=${if finalAttrs.finalPackage.doCheck then "all" else "none"}"
  ];

  preFixup = ''
    gappsWrapperArgs+=(
      # Thumbnailers
      --prefix XDG_DATA_DIRS : "${gdk-pixbuf}/share"
      --prefix XDG_DATA_DIRS : "${libjxl}/share"
      --prefix XDG_DATA_DIRS : "${librsvg}/share"
      --prefix XDG_DATA_DIRS : "${webp-pixbuf-loader}/share"
      --prefix XDG_DATA_DIRS : "${shared-mime-info}/share"
    )
  '';

  postFixup = ''
    # Cannot be in postInstall, otherwise _multioutDocs hook in preFixup will move right back.
    moveToOutput "share/doc" "$devdoc"
  '';

  passthru = {
    updateScript = gnome.updateScript {
      packageName = "nautilus";
    };
  };

  meta = {
    description = "File manager for GNOME";
    homepage = "https://apps.gnome.org/Nautilus/";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    mainProgram = "nautilus";
    teams = [ lib.teams.gnome ];
  };
})

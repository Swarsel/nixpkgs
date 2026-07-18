{
  lib,
  stdenv,
  fetchurl,
  appstream,
  atk,
  dbus,
  desktop-file-utils,
  djvulibre,
  gdk-pixbuf,
  gettext,
  ghostscriptX,
  gi-docgen,
  glib,
  gnome,
  gnome-desktop,
  gobject-introspection,
  gsettings-desktop-schemas,
  gspell,
  gst_all_1,
  gtk3,
  itstool,
  libarchive,
  libgxps,
  libhandy,
  librsvg,
  libsecret,
  libspectre,
  libxml2,
  meson,
  ninja,
  pango,
  pkg-config,
  poppler,
  shared-mime-info,
  texlive,
  wrapGAppsHook3,
  yelp-tools,
  supportMultimedia ? true, # PDF multimedia
  withLibsecret ? true,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "evince";
  version = "48.4";

  src = fetchurl {
    url = "mirror://gnome/sources/evince/${lib.versions.major finalAttrs.version}/evince-${finalAttrs.version}.tar.xz";
    hash = "sha256-8pbFxmKIZjXUzVl+isCvzeeYK+RIZTPCt/CVsmi+hmg=";
  };

  outputs = [
    "out"
    "dev"
    "devdoc"
  ];

  nativeBuildInputs = [
    appstream
    desktop-file-utils
    gettext
    gobject-introspection
    gi-docgen
    itstool
    meson
    ninja
    pkg-config
    wrapGAppsHook3
    yelp-tools
  ];

  buildInputs = [
    atk
    dbus # only needed to find the service directory
    djvulibre
    gdk-pixbuf
    ghostscriptX
    glib
    gnome-desktop
    gsettings-desktop-schemas
    gspell
    gtk3
    libarchive
    libgxps
    libhandy
    librsvg
    libspectre
    libxml2
    pango
    poppler
    texlive.bin.core # kpathsea for DVI support
  ]
  ++ lib.optionals withLibsecret [
    libsecret
  ]
  ++ lib.optionals supportMultimedia (
    with gst_all_1;
    [
      gstreamer
      gst-plugins-base
      gst-plugins-good
      gst-plugins-bad
      gst-plugins-ugly
      gst-libav
    ]
  );

  mesonFlags = [
    "-Dnautilus=false"
    "-Dps=enabled"
  ]
  ++ lib.optionals (!withLibsecret) [
    "-Dkeyring=disabled"
  ]
  ++ lib.optionals (!supportMultimedia) [
    "-Dmultimedia=disabled"
  ];

  # Fix build with gcc15
  env.NIX_CFLAGS_COMPILE = toString [
    "-DHAVE_STRING_H"
    "-DHAVE_STDLIB_H"
  ];

  postInstall = ''
    substituteInPlace $out/share/thumbnailers/evince.thumbnailer \
      --replace-fail "TryExec=evince-thumbnailer" "TryExec=$out/bin/evince-thumbnailer" \
      --replace-fail "Exec=evince-thumbnailer" "Exec=$out/bin/evince-thumbnailer"
  '';

  preFixup = ''
    gappsWrapperArgs+=(--prefix XDG_DATA_DIRS : "${shared-mime-info}/share")
  '';

  postFixup = ''
    # Cannot be in postInstall, otherwise _multioutDocs hook in preFixup will move right back.
    moveToOutput "share/doc" "$devdoc"
  '';

  depsBuildBuild = [
    pkg-config
  ];

  passthru = {
    updateScript = gnome.updateScript {
      # 49.alpha bumps API and breaks sushi.
      freeze = true;
      packageName = "evince";
    };
  };

  meta = {
    description = "GNOME's document viewer";

    longDescription = ''
      Evince is a document viewer for multiple document formats.  It
      currently supports PDF, PostScript, DjVu, TIFF and DVI.  The goal
      of Evince is to replace the multiple document viewers that exist
      on the GNOME Desktop with a single simple application.
    '';

    homepage = "https://apps.gnome.org/Evince/";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.unix;
    mainProgram = "evince";

    teams = [
      lib.teams.gnome
      lib.teams.pantheon
    ];
  };
})

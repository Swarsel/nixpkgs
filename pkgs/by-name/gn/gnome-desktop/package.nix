{
  lib,
  stdenv,
  fetchurl,
  bubblewrap,
  docbook-xsl-nons,
  gettext,
  glib,
  gnome,
  gobject-introspection,
  gsettings-desktop-schemas,
  gtk-doc,
  gtk3,
  gtk4,
  isocodes,
  libseccomp,
  libxkbcommon,
  libxml2,
  libxslt,
  meson,
  ninja,
  pkg-config,
  replaceVars,
  systemd,
  udev,
  wayland,
  xkeyboard_config,
  withSystemd ? lib.meta.availableOn stdenv.hostPlatform systemd,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gnome-desktop";
  version = "44.5";

  src = fetchurl {
    url = "mirror://gnome/sources/gnome-desktop/${lib.versions.major finalAttrs.version}/gnome-desktop-${finalAttrs.version}.tar.xz";
    sha256 = "sha256-IOCZWm46A+jBAmxaJ7w/Reaf/MOSrXQ9yrYQelQdIy8=";
  };

  outputs = [
    "out"
    "dev"
    "devdoc"
  ];

  patches = lib.optionals stdenv.hostPlatform.isLinux [
    (replaceVars ./bubblewrap-paths.patch {
      inherit (builtins) storeDir;
      bubblewrap_bin = "${bubblewrap}/bin/bwrap";
    })
  ];

  nativeBuildInputs = [
    pkg-config
    meson
    ninja
    gettext
    libxslt
    libxml2
    gobject-introspection
    gtk-doc
    docbook-xsl-nons
    glib
  ];

  buildInputs = [
    xkeyboard_config
    libxkbcommon # for xkbregistry
    isocodes
    gtk3
    gtk4
    glib
  ]
  ++ lib.optionals withSystemd [
    systemd
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    bubblewrap
    wayland
    libseccomp
    udev
  ];

  propagatedBuildInputs = [
    gsettings-desktop-schemas
  ];

  mesonFlags = [
    "-Dgtk_doc=true"
    "-Ddesktop_docs=false"
    (lib.mesonEnable "systemd" withSystemd)
  ]
  ++ lib.optionals (!stdenv.hostPlatform.isLinux) [
    "-Dudev=disabled"
  ];

  separateDebugInfo = stdenv.hostPlatform.isLinux;

  passthru = {
    updateScript = gnome.updateScript {
      packageName = "gnome-desktop";
    };
  };

  meta = {
    description = "Library with common API for various GNOME modules";
    homepage = "https://gitlab.gnome.org/GNOME/gnome-desktop";

    license = with lib.licenses; [
      gpl2Plus
      lgpl2Plus
    ];

    platforms = lib.platforms.unix;
    badPlatforms = lib.platforms.darwin;
    teams = [ lib.teams.gnome ];
  };
})

{
  lib,
  stdenv,
  fetchurl,
  cairo,
  cyrus_sasl,
  gdk-pixbuf,
  gettext,
  gi-docgen,
  glib,
  gmp,
  gnome,
  gnutls,
  gobject-introspection,
  gtk3,
  libpulseaudio,
  meson,
  ninja,
  perl,
  pkg-config,
  python3,
  vala,
  zlib,
  pulseaudioSupport ? stdenv.hostPlatform.isLinux,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gtk-vnc";
  version = "1.5.0";

  src = fetchurl {
    url = "mirror://gnome/sources/gtk-vnc/${lib.versions.majorMinor finalAttrs.version}/gtk-vnc-${finalAttrs.version}.tar.xz";
    sha256 = "wL60dHUorZMdpDrMVnxqAZD3/GJEZVce2czs4Cw03SM=";
  };

  outputs = [
    "out"
    "bin"
    "man"
    "dev"
    "devdoc"
  ];

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    gobject-introspection
    vala
    gettext
    perl # for pod2man
    python3
    gi-docgen
  ];

  buildInputs = [
    gnutls
    cairo
    gdk-pixbuf
    zlib
    glib
    gmp
    cyrus_sasl
    gtk3
  ]
  ++ lib.optionals pulseaudioSupport [
    libpulseaudio
  ];

  mesonFlags = lib.optionals (!pulseaudioSupport) [
    "-Dpulseaudio=disabled"
  ];

  postFixup = ''
    # Cannot be in postInstall, otherwise _multioutDocs hook in preFixup will move right back.
    moveToOutput "share/doc" "$devdoc"
  '';

  passthru = {
    updateScript = gnome.updateScript {
      packageName = "gtk-vnc";
      versionPolicy = "none";
    };
  };

  meta = {
    description = "GTK VNC widget";
    homepage = "https://gitlab.gnome.org/GNOME/gtk-vnc";
    license = lib.licenses.lgpl2Plus;

    maintainers = with lib.maintainers; [
      raskin
    ];

    platforms = lib.platforms.unix;
    mainProgram = "gvnccapture";
  };
})

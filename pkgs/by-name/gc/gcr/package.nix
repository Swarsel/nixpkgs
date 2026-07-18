{
  lib,
  stdenv,
  fetchurl,
  gettext,
  gi-docgen,
  glib,
  gnome,
  gnupg,
  gobject-introspection,
  gtk3,
  libgcrypt,
  libsecret,
  libtasn1,
  meson,
  ninja,
  openssh,
  p11-kit,
  pango,
  pkg-config,
  python3,
  shared-mime-info,
  systemd,
  vala,
  wrapGAppsHook3,
  systemdSupport ? lib.meta.availableOn stdenv.hostPlatform systemd,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gcr";
  version = "3.41.2";

  src = fetchurl {
    url = "mirror://gnome/sources/gcr/${lib.versions.majorMinor finalAttrs.version}/gcr-${finalAttrs.version}.tar.xz";
    sha256 = "utEPPFU6DhhUZJq1nFskNNoiyhpUrmE48fU5YVZ+Grc=";
  };

  outputs = [
    "out"
    "dev"
    "devdoc"
  ];

  postPatch = ''
    patchShebangs gcr/fixtures/

    chmod +x meson_post_install.py
    patchShebangs meson_post_install.py
    substituteInPlace meson_post_install.py --replace ".so" "${stdenv.hostPlatform.extensions.sharedLibrary}"
  '';

  strictDeps = true;

  nativeBuildInputs = [
    pkg-config
    meson
    python3
    ninja
    gettext
    gobject-introspection
    gi-docgen
    wrapGAppsHook3
    vala
    shared-mime-info
    openssh
  ];

  buildInputs = [
    libgcrypt
    libtasn1
    pango
    libsecret
    openssh
  ]
  ++ lib.optionals systemdSupport [
    systemd
  ];

  propagatedBuildInputs = [
    glib
    gtk3
    p11-kit
  ];

  mesonFlags = [
    # We are still using ssh-agent from gnome-keyring.
    # https://github.com/NixOS/nixpkgs/issues/140824
    "-Dssh_agent=false"
    "-Dgpg_path=${lib.getBin gnupg}/bin/gpg"
  ]
  ++ lib.optionals (!systemdSupport) [
    "-Dsystemd=disabled"
  ];

  env.PKG_CONFIG_SYSTEMD_SYSTEMDUSERUNITDIR = "${placeholder "out"}/lib/systemd/user";
  doCheck = false; # fails 21 out of 603 tests, needs dbus daemon

  nativeCheckInputs = [
    python3
  ];

  postFixup = ''
    # Cannot be in postInstall, otherwise _multioutDocs hook in preFixup will move right back.
    moveToOutput "share/doc" "$devdoc"
  '';

  passthru = {
    updateScript = gnome.updateScript {
      freeze = true;
      packageName = "gcr";
    };
  };

  meta = {
    description = "GNOME crypto services (daemon and tools)";

    longDescription = ''
      GCR is a library for displaying certificates, and crypto UI, accessing
      key stores. It also provides the viewer for crypto files on the GNOME
      desktop.

      GCK is a library for accessing PKCS#11 modules like smart cards, in a
      (G)object oriented way.
    '';

    homepage = "https://gitlab.gnome.org/GNOME/gcr";
    license = lib.licenses.lgpl2Plus;
    platforms = lib.platforms.unix;
    mainProgram = "gcr-viewer";
    teams = [ lib.teams.gnome ];
  };
})

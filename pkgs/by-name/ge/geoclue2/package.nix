{
  lib,
  stdenv,
  fetchFromGitLab,
  avahi,
  docbook-xsl-nons,
  docbook_xml_dtd_412,
  gdk-pixbuf,
  glib,
  glib-networking,
  gobject-introspection,
  gtk-doc,
  intltool,
  json-glib,
  libnotify,
  libsoup_3,
  meson,
  mesonEmulatorHook,
  modemmanager,
  ninja,
  nix-update-script,
  nixosTests,
  pkg-config,
  python3,
  vala,
  wrapGAppsHook3,
  withDemoAgent ? false,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "geoclue";
  version = "2.7.2";

  src = fetchFromGitLab {
    owner = "geoclue";
    repo = "geoclue";
    tag = finalAttrs.version;
    hash = "sha256-LwL1WtCdHb/NwPr3/OLISwaAwplhJwiZT9vUdX29Bbs=";
    domain = "gitlab.freedesktop.org";
  };

  outputs = [
    "out"
    "dev"
    "devdoc"
  ];

  patches = [
    ./add-option-for-installation-sysconfdir.patch
  ];

  postPatch = ''
    chmod +x demo/install-file.py
    patchShebangs demo/install-file.py
  '';

  nativeBuildInputs = [
    pkg-config
    intltool
    meson
    ninja
    wrapGAppsHook3
    python3
    vala
    gobject-introspection
    # devdoc
    gtk-doc
    docbook-xsl-nons
    docbook_xml_dtd_412
  ]
  ++ lib.optionals (!stdenv.buildPlatform.canExecute stdenv.hostPlatform) [
    mesonEmulatorHook
  ];

  buildInputs = [
    glib
    json-glib
    libsoup_3
    avahi
  ]
  ++ lib.optionals withDemoAgent [
    libnotify
    gdk-pixbuf
  ]
  ++ lib.optionals (!stdenv.hostPlatform.isDarwin) [
    modemmanager
  ];

  propagatedBuildInputs = [
    glib
    glib-networking
  ];

  mesonFlags = [
    "-Dsystemd-system-unit-dir=${placeholder "out"}/lib/systemd/system"
    "-Ddemo-agent=${lib.boolToString withDemoAgent}"
    "--sysconfdir=/etc"
    "-Dsysconfdir_install=${placeholder "out"}/etc"
    "-Ddbus-srv-user=geoclue"
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    "-D3g-source=false"
    "-Dcdma-source=false"
    "-Dmodem-gps-source=false"
    "-Dnmea-source=false"
  ];

  separateDebugInfo = true;

  passthru = {
    tests = {
      inherit (nixosTests) geoclue2;
    };

    updateScript = nix-update-script { };
  };

  meta = {
    description = "Geolocation framework and some data providers";
    homepage = "https://gitlab.freedesktop.org/geoclue/geoclue/wikis/home";
    changelog = "https://gitlab.freedesktop.org/geoclue/geoclue/-/blob/${finalAttrs.version}/NEWS";
    license = lib.licenses.lgpl2Plus;

    maintainers = with lib.maintainers; [
      raskin
      mimame
    ];

    platforms = with lib.platforms; linux ++ darwin;
    broken = stdenv.hostPlatform.isDarwin && withDemoAgent;
  };
})

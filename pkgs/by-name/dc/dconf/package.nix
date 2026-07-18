{
  lib,
  stdenv,
  fetchurl,
  bash-completion,
  buildPackages,
  dbus,
  docbook-xsl-nons,
  docbook_xml_dtd_42,
  glib,
  gnome,
  gobject-introspection,
  gtk-doc,
  libxslt,
  meson,
  mesonEmulatorHook,
  ninja,
  nixosTests,
  pkg-config,
  python3,
  vala,
  withDocs ? withIntrospection,
  withIntrospection ?
    lib.meta.availableOn stdenv.hostPlatform gobject-introspection
    && stdenv.hostPlatform.emulatorAvailable buildPackages,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "dconf";
  version = "0.49.0";

  src = fetchurl {
    url = "mirror://gnome/sources/dconf/${lib.versions.majorMinor finalAttrs.version}/dconf-${finalAttrs.version}.tar.xz";
    sha256 = "FqR+SaWBVtu5ZXjhcIMlKZ5MGe6pvhKNW9Ev0JY9bDY=";
  };

  outputs = [
    "out"
    "lib"
    "dev"
  ]
  ++ lib.optional withDocs "devdoc";

  postPatch = ''
    chmod +x tests/test-dconf.py tests/shellcheck.sh
    patchShebangs tests/test-dconf.py tests/shellcheck.sh
  '';

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    python3
    libxslt
    glib
    docbook-xsl-nons
    docbook_xml_dtd_42
    gtk-doc
  ]
  ++ lib.optionals (withDocs && !stdenv.buildPlatform.canExecute stdenv.hostPlatform) [
    mesonEmulatorHook # gtkdoc invokes the host binary to produce documentation
  ];

  buildInputs = [
    glib
    bash-completion
    dbus
  ]
  ++ lib.optionals withIntrospection [
    vala
  ];

  mesonFlags = [
    "--sysconfdir=/etc"
    (lib.mesonBool "gtk_doc" withDocs)
    (lib.mesonBool "vapi" withIntrospection)
  ];

  doCheck =
    !stdenv.hostPlatform.isAarch32 && !stdenv.hostPlatform.isAarch64 && !stdenv.hostPlatform.isDarwin;

  nativeCheckInputs = [
    dbus # for dbus-daemon
  ];

  passthru = {
    tests = { inherit (nixosTests) dconf; };

    updateScript = gnome.updateScript {
      packageName = "dconf";
    };
  };

  meta = {
    homepage = "https://gitlab.gnome.org/GNOME/dconf";
    license = lib.licenses.lgpl21Plus;
    platforms = lib.platforms.unix;

    badPlatforms = [
      # Mandatory libdconfsettings shared library.
      lib.systems.inspect.platformPatterns.isStatic
    ];

    mainProgram = "dconf";
    teams = [ lib.teams.gnome ];
  };
})

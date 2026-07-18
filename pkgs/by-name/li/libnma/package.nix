{
  lib,
  stdenv,
  fetchurl,
  _experimental-update-script-combinators,
  docbook_xml_dtd_43,
  docbook_xsl,
  gcr_4,
  gettext,
  glib,
  gnome,
  gobject-introspection,
  gtk-doc,
  gtk3,
  gtk4,
  isocodes,
  libxml2,
  makeHardcodeGsettingsPatch,
  meson,
  mesonEmulatorHook,
  mobile-broadband-provider-info,
  networkmanager,
  ninja,
  pkg-config,
  vala,
  withGnome ? true,
  withGtk4 ? false,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libnma";
  version = "1.10.6";

  src = fetchurl {
    url = "mirror://gnome/sources/libnma/${lib.versions.majorMinor finalAttrs.version}/libnma-${finalAttrs.version}.tar.xz";
    sha256 = "U6b7KxkK03xZhsrtPpi+3nw8YCOZ7k+TyPwFQwPXbas=";
  };

  outputs = [
    "out"
    "dev"
    "devdoc"
  ];

  patches = [
    # Needed for wingpanel-indicator-network and switchboard-plug-network
    ./hardcode-gsettings.patch
  ];

  postPatch = ''
    substituteInPlace src/nma-ws/nma-eap.c --subst-var-by \
      NM_APPLET_GSETTINGS ${glib.makeSchemaPath "$out" "$name"}
  '';

  nativeBuildInputs = [
    meson
    ninja
    gettext
    pkg-config
    gobject-introspection
    gtk-doc
    docbook_xsl
    docbook_xml_dtd_43
    libxml2
    vala
  ]
  ++ lib.optionals (!stdenv.buildPlatform.canExecute stdenv.hostPlatform) [
    mesonEmulatorHook
  ];

  buildInputs = [
    gtk3
    networkmanager
    isocodes
    mobile-broadband-provider-info
  ]
  ++ lib.optionals withGtk4 [
    gtk4
  ]
  ++ lib.optionals withGnome [
    # advanced certificate chooser
    gcr_4
  ];

  mesonFlags = [
    "-Dgcr=${lib.boolToString withGnome}"
    "-Dlibnma_gtk4=${lib.boolToString withGtk4}"
  ];

  postInstall = ''
    glib-compile-schemas $out/share/glib-2.0/schemas
  '';

  passthru = {
    hardcodeGsettingsPatch = makeHardcodeGsettingsPatch {
      inherit (finalAttrs) src;

      schemaIdToVariableMapping = {
        "org.gnome.nm-applet.eap" = "NM_APPLET_GSETTINGS";
      };
    };

    updateScript =
      let
        updateSource = gnome.updateScript {
          packageName = "libnma";
          versionPolicy = "odd-unstable";
        };
        updateGsettingsPatch = _experimental-update-script-combinators.copyAttrOutputToFile "libnma.hardcodeGsettingsPatch" ./hardcode-gsettings.patch;
      in
      _experimental-update-script-combinators.sequence [
        updateSource
        updateGsettingsPatch
      ];
  };

  meta = {
    description = "NetworkManager UI utilities (libnm version)";
    homepage = "https://gitlab.gnome.org/GNOME/libnma";
    license = lib.licenses.gpl2Plus; # Mix of GPL and LPGL 2+
    platforms = lib.platforms.linux;
    teams = [ lib.teams.gnome ];
  };
})

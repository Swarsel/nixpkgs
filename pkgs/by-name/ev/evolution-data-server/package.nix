{
  lib,
  stdenv,
  fetchurl,
  _experimental-update-script-combinators,
  boost,
  buildPackages,
  cmake,
  db,
  gettext,
  glib,
  glib-networking,
  gnome,
  gnome-online-accounts,
  gobject-introspection,
  gperf,
  gsettings-desktop-schemas,
  gtk3,
  gtk4,
  icu,
  json-glib,
  libcanberra-gtk3,
  libgweather,
  libical,
  libiconv,
  libkrb5,
  libphonenumber,
  libsecret,
  libsoup_3,
  libuuid,
  libxml2,
  makeHardcodeGsettingsPatch,
  ninja,
  nspr,
  nss,
  openldap,
  p11-kit,
  pkg-config,
  protobuf,
  python3,
  sqlite,
  vala,
  webkitgtk_4_1,
  webkitgtk_6_0,
  wrapGAppsHook3,
  enableOAuth2 ? stdenv.hostPlatform.isLinux,
  withGtk3 ? true,
  withGtk4 ? false,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "evolution-data-server";
  version = "3.60.2";

  src = fetchurl {
    url = "mirror://gnome/sources/evolution-data-server/${lib.versions.majorMinor finalAttrs.version}/evolution-data-server-${finalAttrs.version}.tar.xz";
    hash = "sha256-IITb2sOWNxs2XVBMH/RYZrqNyi8SUuXaHT2cM6vcEoY=";
  };

  outputs = [
    "out"
    "dev"
  ];

  patches = [
    # Avoid using wrapper function, which the hardcode gsettings
    # patch generator cannot handle.
    ./drop-tentative-settings-constructor.patch
  ];

  postPatch =
    lib.optionalString stdenv.hostPlatform.isDarwin ''
      substituteInPlace cmake/modules/SetupBuildFlags.cmake \
        --replace "-Wl,--no-undefined" ""
      substituteInPlace src/services/evolution-alarm-notify/e-alarm-notify.c \
        --replace "G_OS_WIN32" "__APPLE__"
    ''
    + lib.optionalString (!stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
      substituteInPlace src/addressbook/libebook-contacts/CMakeLists.txt --replace-fail \
        'COMMAND ''${CMAKE_CURRENT_BINARY_DIR}/gen-western-table' \
        'COMMAND ${stdenv.hostPlatform.emulator buildPackages} ''${CMAKE_CURRENT_BINARY_DIR}/gen-western-table'
      substituteInPlace src/camel/CMakeLists.txt --replace-fail \
        'COMMAND ''${CMAKE_CURRENT_BINARY_DIR}/camel-gen-tables' \
        'COMMAND ${stdenv.hostPlatform.emulator buildPackages} ''${CMAKE_CURRENT_BINARY_DIR}/camel-gen-tables'
    '';

  strictDeps = true;

  nativeBuildInputs = [
    cmake
    ninja
    pkg-config
    gettext
    python3
    gperf
    wrapGAppsHook3
    gobject-introspection
    vala
  ];

  buildInputs = [
    glib
    libsecret
    libsoup_3
    gnome-online-accounts
    p11-kit
    libgweather
    icu
    sqlite
    libkrb5
    openldap
    glib-networking
    libcanberra-gtk3
    libphonenumber
    libuuid
    boost
    protobuf
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    libiconv
  ]
  ++ lib.optionals withGtk3 [
    gtk3
  ]
  ++ lib.optionals (withGtk3 && enableOAuth2) [
    webkitgtk_4_1
  ]
  ++ lib.optionals withGtk4 [
    gtk4
  ]
  ++ lib.optionals (withGtk4 && enableOAuth2) [
    webkitgtk_6_0
  ];

  propagatedBuildInputs = [
    db
    nss
    nspr
    libical
    libsoup_3
    libxml2
    json-glib
  ];

  cmakeFlags = [
    "-DENABLE_VALA_BINDINGS=ON"
    "-DENABLE_INTROSPECTION=ON"
    "-DINCLUDE_INSTALL_DIR=${placeholder "dev"}/include"
    "-DWITH_PHONENUMBER=ON"
    "-DENABLE_GTK=${lib.boolToString withGtk3}"
    "-DENABLE_EXAMPLES=${lib.boolToString withGtk3}"
    "-DENABLE_CANBERRA=${lib.boolToString withGtk3}"
    "-DENABLE_GTK4=${lib.boolToString withGtk4}"
    "-DENABLE_OAUTH2_WEBKITGTK=${lib.boolToString (withGtk3 && enableOAuth2)}"
    "-DENABLE_OAUTH2_WEBKITGTK4=${lib.boolToString (withGtk4 && enableOAuth2)}"
  ]
  ++ lib.optionals (!stdenv.buildPlatform.canExecute stdenv.hostPlatform) [
    (lib.cmakeFeature "CMAKE_CROSSCOMPILING_EMULATOR" (stdenv.hostPlatform.emulator buildPackages))
  ];

  postInstall = lib.optionalString stdenv.hostPlatform.isDarwin ''
    ln -s $out/lib/evolution-data-server/*.dylib $out/lib/
  '';

  prePatch = ''
    substitute ${./hardcode-gsettings.patch} hardcode-gsettings.patch \
      --subst-var-by EDS ${glib.makeSchemaPath "$out" "evolution-data-server-${finalAttrs.version}"} \
      --subst-var-by GDS ${glib.getSchemaPath gsettings-desktop-schemas}
    patches="$patches $PWD/hardcode-gsettings.patch"
  '';

  passthru = {
    hardcodeGsettingsPatch = makeHardcodeGsettingsPatch {
      inherit (finalAttrs) src patches;

      schemaIdToVariableMapping = {
        "org.gnome.Evolution.DefaultSources" = "EDS";
        "org.gnome.desktop.interface" = "GDS";
        "org.gnome.evolution-data-server" = "EDS";
        "org.gnome.evolution-data-server.addressbook" = "EDS";
        "org.gnome.evolution-data-server.calendar" = "EDS";
        "org.gnome.evolution.shell.network-config" = "EDS";
      };
    };

    updateScript =
      let
        updateSource = gnome.updateScript {
          packageName = "evolution-data-server";
          versionPolicy = "odd-unstable";
        };
        updatePatch = _experimental-update-script-combinators.copyAttrOutputToFile "evolution-data-server.hardcodeGsettingsPatch" ./hardcode-gsettings.patch;
      in
      _experimental-update-script-combinators.sequence [
        updateSource
        updatePatch
      ];
  };

  meta = {
    description = "Unified backend for programs that work with contacts, tasks, and calendar information";
    homepage = "https://gitlab.gnome.org/GNOME/evolution-data-server";
    changelog = "https://gitlab.gnome.org/GNOME/evolution-data-server/-/blob/${finalAttrs.version}/NEWS?ref_type=tags";
    license = lib.licenses.lgpl2Plus;
    platforms = lib.platforms.linux; # requires libuuid
    teams = [ lib.teams.gnome ];
  };
})

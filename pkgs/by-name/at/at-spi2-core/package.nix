{
  lib,
  stdenv,
  fetchurl,
  buildPackages,
  dbus,
  dconf,
  glib,
  gnome,
  gobject-introspection,
  gsettings-desktop-schemas,
  libx11,
  libxext,
  libxi,
  libxml2,
  libxtst,
  makeWrapper,
  meson,
  ninja,
  pkg-config,
  python3,
  systemdLibs,
  systemdSupport ? lib.meta.availableOn stdenv.hostPlatform systemdLibs,
  withDconf ? !stdenv.hostPlatform.isDarwin && lib.meta.availableOn stdenv.hostPlatform dconf,
  withIntrospection ?
    lib.meta.availableOn stdenv.hostPlatform gobject-introspection
    && stdenv.hostPlatform.emulatorAvailable buildPackages,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "at-spi2-core";
  version = "2.60.4";

  src = fetchurl {
    url = "mirror://gnome/sources/at-spi2-core/${lib.versions.majorMinor finalAttrs.version}/at-spi2-core-${finalAttrs.version}.tar.xz";
    hash = "sha256-Gh9bqYBZF/QfxqpoI9z4h6KR1gekJ+LVr7a136ZQcMc=";
  };

  outputs = [
    "out"
    "dev"
  ];

  nativeBuildInputs = [
    glib
    meson
    ninja
    pkg-config
    makeWrapper
    python3
  ]
  ++ lib.optionals withIntrospection [
    gobject-introspection
  ];

  buildInputs = [
    libx11
    libxml2
    # at-spi2-core can be build without X support, but due it is a client-side library, GUI-less usage is a very rare case
    libxtst
    libxi
    # libxext is a transitive dependency of libxi
    libxext
  ]
  ++ lib.optionals systemdSupport [
    # libsystemd is a needed for dbus-broker support
    systemdLibs
  ];

  # In atspi-2.pc dbus-1 glib-2.0
  # In atk.pc gobject-2.0
  propagatedBuildInputs = [
    dbus
    glib
  ];

  mesonFlags = [
    # Provide dbus-daemon fallback when it is not already running when
    # at-spi2-bus-launcher is executed. This allows us to avoid
    # including the entire dbus closure in libraries linked with
    # the at-spi2-core libraries.
    "-Ddbus_daemon=/run/current-system/sw/bin/dbus-daemon"
  ]
  ++ lib.optionals systemdSupport [
    # Same as the above, but for dbus-broker
    "-Ddbus_broker=/run/current-system/sw/bin/dbus-broker-launch"
  ]
  ++ lib.optionals (!systemdSupport) [
    "-Duse_systemd=false"
  ]
  ++ lib.optionals (!withIntrospection) [
    (lib.mesonEnable "introspection" false)
  ]
  ++ lib.optionals stdenv.hostPlatform.isStatic [
    # The adaptor is only available as a shared object, as gtk2 loads it dynamically
    (lib.mesonBool "gtk2_atk_adaptor" false)
  ];

  # fails with "AT-SPI: Couldn't connect to accessibility bus. Is at-spi-bus-launcher running?"
  doCheck = false;

  postFixup = ''
    # Cannot use wrapGAppsHook'due to a dependency cycle
    wrapProgram $out/libexec/at-spi-bus-launcher \
      ${lib.optionalString withDconf ''--prefix GIO_EXTRA_MODULES : "${lib.getLib dconf}/lib/gio/modules"''} \
      --prefix XDG_DATA_DIRS : ${gsettings-desktop-schemas}/share/gsettings-schemas/${gsettings-desktop-schemas.name}
  '';

  separateDebugInfo = true;

  passthru = {
    updateScript = gnome.updateScript {
      packageName = "at-spi2-core";
      versionPolicy = "odd-unstable";
    };
  };

  meta = {
    description = "Assistive Technology Service Provider Interface protocol definitions and daemon for D-Bus";
    homepage = "https://gitlab.gnome.org/GNOME/at-spi2-core";
    license = lib.licenses.lgpl21Plus;
    maintainers = with lib.maintainers; [ raskin ];
    platforms = lib.platforms.unix;
    teams = [ lib.teams.gnome ];
  };
})

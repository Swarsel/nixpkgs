{
  lib,
  stdenv,
  fetchurl,
  buildPackages,
  glib,
  glibcLocales,
  gnome,
  gobject-introspection,
  meson,
  ninja,
  pkg-config,
  udev,
  umockdev,
  vala,
  withIntrospection ?
    lib.meta.availableOn stdenv.hostPlatform gobject-introspection
    && stdenv.hostPlatform.emulatorAvailable buildPackages,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libgudev";
  version = "238";

  src = fetchurl {
    url = "mirror://gnome/sources/libgudev/${lib.versions.majorMinor finalAttrs.version}/libgudev-${finalAttrs.version}.tar.xz";
    hash = "sha256-YSZqsa/J1z28YKiyr3PpnS/f9H2ZVE0IV2Dk+mZ7XdE=";
  };

  outputs = [
    "out"
    "dev"
  ];

  patches = [
    # Conditionally disable one test that requires a locale implementation
    # https://gitlab.gnome.org/GNOME/libgudev/-/merge_requests/31
    ./tests-skip-double-test-on-stub-locale-impls.patch
  ];

  postPatch = lib.optionalString finalAttrs.finalPackage.doCheck ''
    # The relative location of LD_PRELOAD works for Glibc but not for other loaders (e.g. pkgsMusl)
    substituteInPlace tests/meson.build \
      --replace "LD_PRELOAD=libumockdev-preload.so.0" "LD_PRELOAD=${lib.getLib umockdev}/lib/libumockdev-preload.so.0"
  '';

  strictDeps = true;

  nativeBuildInputs = [
    pkg-config
    meson
    ninja
    glib # for glib-mkenums needed during the build
  ]
  ++ lib.optionals withIntrospection [
    gobject-introspection
    vala
  ];

  buildInputs = [
    udev
    glib
  ];

  mesonFlags = [
    (lib.mesonEnable "introspection" withIntrospection)
    (lib.mesonEnable "vapi" withIntrospection)
    (lib.mesonEnable "tests" finalAttrs.finalPackage.doCheck)
  ];

  doCheck = withIntrospection;

  checkInputs = [
    glibcLocales
    umockdev
  ];

  # https://gitlab.gnome.org/GNOME/libgudev/-/issues/10
  preCheck = ''
    mesonCheckFlagsArray=( $(meson test --list | grep -v libgudev:test-gudevdevice) )
  '';

  passthru = {
    updateScript = gnome.updateScript {
      packageName = "libgudev";
      versionPolicy = "none";
    };
  };

  meta = {
    description = "Library that provides GObject bindings for libudev";
    homepage = "https://gitlab.gnome.org/GNOME/libgudev";
    license = lib.licenses.lgpl2Plus;
    platforms = lib.platforms.linux;
    teams = [ lib.teams.gnome ];
  };
})

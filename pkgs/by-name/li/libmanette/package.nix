{
  lib,
  stdenv,
  fetchurl,
  buildPackages,
  gi-docgen,
  glib,
  gnome,
  gobject-introspection,
  hidapi,
  libevdev,
  libgudev,
  meson,
  mesonEmulatorHook,
  ninja,
  pkg-config,
  vala,
  withIntrospection ?
    lib.meta.availableOn stdenv.hostPlatform gobject-introspection
    && stdenv.hostPlatform.emulatorAvailable buildPackages,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libmanette";
  version = "0.2.13";

  src = fetchurl {
    url = "mirror://gnome/sources/libmanette/${lib.versions.majorMinor finalAttrs.version}/libmanette-${finalAttrs.version}.tar.xz";
    hash = "sha256-KHzC/eDeCSkZNmr3V9heezoCSOsbOVNEcm6XlVp32K4=";
  };

  outputs = [
    "out"
    "dev"
  ]
  ++ lib.optional withIntrospection "devdoc";

  strictDeps = true;

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    glib
  ]
  ++ lib.optionals withIntrospection [
    vala
    gobject-introspection
    gi-docgen
  ]
  ++ lib.optionals (withIntrospection && !stdenv.buildPlatform.canExecute stdenv.hostPlatform) [
    mesonEmulatorHook
  ];

  buildInputs = [
    glib
    libevdev
    hidapi
  ]
  ++ lib.optionals withIntrospection [
    libgudev
  ];

  mesonFlags = [
    (lib.mesonBool "doc" withIntrospection)
    (lib.mesonEnable "gudev" withIntrospection)
    (lib.mesonBool "introspection" withIntrospection)
    (lib.mesonBool "vapi" withIntrospection)
  ];

  doCheck = true;

  postFixup = ''
    # Cannot be in postInstall, otherwise _multioutDocs hook in preFixup will move right back.
    moveToOutput "share/doc" "$devdoc"
  '';

  depsBuildBuild = lib.optionals withIntrospection [
    pkg-config
  ];

  passthru = {
    updateScript = gnome.updateScript {
      packageName = "libmanette";
      versionPolicy = "odd-unstable";
    };
  };

  meta = {
    description = "Simple GObject game controller library";
    homepage = "https://gnome.pages.gitlab.gnome.org/libmanette/";
    license = lib.licenses.lgpl21Plus;
    platforms = lib.platforms.unix;
    mainProgram = "manette-test";
    teams = [ lib.teams.gnome ];
  };
})

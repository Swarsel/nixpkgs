{
  lib,
  stdenv,
  fetchurl,
  cairomm_1_16,
  glib,
  glibmm_2_68,
  gnome,
  gtk4,
  libepoxy,
  makeFontsConf,
  meson,
  ninja,
  pangomm_2_48,
  pkg-config,
  python3,
  xvfb-run,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gtkmm";
  version = "4.22.0";

  src = fetchurl {
    url = "mirror://gnome/sources/gtkmm/${lib.versions.majorMinor finalAttrs.version}/gtkmm-${finalAttrs.version}.tar.xz";
    hash = "sha256-LoohtLByX2IOM6ruDNND7RIbUzJ1tjKJZhmxyJ6W3mc=";
  };

  outputs = [
    "out"
    "dev"
  ];

  nativeBuildInputs = [
    pkg-config
    meson
    ninja
    python3
    glib # glib-compile-resources
  ];

  buildInputs = [
    libepoxy
  ];

  propagatedBuildInputs = [
    glibmm_2_68
    gtk4
    cairomm_1_16
    pangomm_2_48
  ];

  # Tests require fontconfig.
  env.FONTCONFIG_FILE = makeFontsConf {
    fontDirectories = [ ];
  };

  doCheck = true;

  nativeCheckInputs = lib.optionals (!stdenv.hostPlatform.isDarwin) [
    xvfb-run
  ];

  checkPhase = ''
    runHook preCheck

    ${lib.optionalString (!stdenv.hostPlatform.isDarwin) "xvfb-run -s '-screen 0 800x600x24'"} \
      meson test --print-errorlogs

    runHook postCheck
  '';

  passthru = {
    updateScript = gnome.updateScript {
      attrPath = "gtkmm4";
      packageName = "gtkmm";
      versionPolicy = "odd-unstable";
    };
  };

  meta = {
    description = "C++ interface to the GTK graphical user interface library";

    longDescription = ''
      gtkmm is the official C++ interface for the popular GUI library
      GTK.  Highlights include typesafe callbacks, and a
      comprehensive set of widgets that are easily extensible via
      inheritance.  You can create user interfaces either in code or
      with the Glade User Interface designer, using libglademm.
      There's extensive documentation, including API reference and a
      tutorial.
    '';

    homepage = "https://gtkmm.org/";
    license = lib.licenses.lgpl2Plus;
    maintainers = with lib.maintainers; [ raskin ];
    platforms = lib.platforms.unix;
    teams = [ lib.teams.gnome ];
  };
})

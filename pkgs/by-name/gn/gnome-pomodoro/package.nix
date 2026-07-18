{
  lib,
  stdenv,
  fetchFromGitHub,
  desktop-file-utils,
  gettext,
  glib,
  gobject-introspection,
  gom,
  gsettings-desktop-schemas,
  gst_all_1,
  gtk3,
  json-glib,
  libcanberra,
  libpeas,
  libxml2,
  meson,
  ninja,
  pkg-config,
  replaceVars,
  sqlite,
  vala,
  wrapGAppsHook3,
}:
stdenv.mkDerivation rec {
  pname = "gnome-pomodoro";
  version = "0.28.1";

  src = fetchFromGitHub {
    owner = "focustimerhq";
    repo = "FocusTimer";
    rev = version;
    hash = "sha256-1G0Sv6uR4rE+/TZqEM57mCdBaXoJNpC0cznY4pnPEa4=";
  };

  patches = [
    # Our glib setup hooks moves GSettings schemas to a subdirectory to prevent conflicts.
    # We need to patch the build script so that the extension can find them.
    (replaceVars ./fix-schema-path.patch {
      inherit pname version;
    })
  ];

  nativeBuildInputs = [
    meson
    ninja
    gettext
    gobject-introspection
    libxml2
    pkg-config
    vala
    wrapGAppsHook3
    desktop-file-utils
  ];

  buildInputs = [
    glib
    gom
    gsettings-desktop-schemas
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
    gst_all_1.gstreamer
    gtk3
    json-glib
    libcanberra
    libpeas
    sqlite
  ];

  # Manually compile schemas for package since meson option
  # gnome.post_install(glib_compile_schemas) used by package tries to compile in
  # the wrong dir.
  preFixup = ''
    glib-compile-schemas ${glib.makeSchemaPath "$out" "${pname}-${version}"}
  '';

  meta = {
    description = "Time management utility for GNOME based on the pomodoro technique";

    longDescription = ''
      This GNOME utility helps to manage time according to Pomodoro Technique.
      It intends to improve productivity and focus by taking short breaks.
    '';

    homepage = "https://gnomepomodoro.org/";
    license = lib.licenses.gpl3Plus;

    maintainers = with lib.maintainers; [
      aleksana
      herschenglime
    ];

    platforms = lib.platforms.linux;
    mainProgram = "gnome-pomodoro";
  };
}

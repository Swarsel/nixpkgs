{
  lib,
  stdenv,
  fetchurl,
  adwaita-icon-theme,
  desktop-file-utils,
  geoclue2,
  gjs,
  gnome,
  gobject-introspection,
  gsettings-desktop-schemas,
  gtk4,
  libadwaita,
  libgweather,
  meson,
  ninja,
  pkg-config,
  python3,
  typescript,
  wrapGAppsHook4,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gnome-weather";
  version = "50.0";

  src = fetchurl {
    url = "mirror://gnome/sources/gnome-weather/${lib.versions.major finalAttrs.version}/gnome-weather-${finalAttrs.version}.tar.xz";
    hash = "sha256-V951eGBfkfmrQAVRznc423UFvIj0KjPHDOenAWf9tRM=";
  };

  postPatch = ''
    # The .service file is not wrapped with the correct environment
    # so misses GIR files when started. By re-pointing from the gjs
    # entry point to the wrapped binary we get back to a wrapped
    # binary.
    substituteInPlace "data/org.gnome.Weather.service.in" \
        --replace-fail "Exec=@DATA_DIR@/@APP_ID@" "Exec=$out/bin/gnome-weather"

    chmod +x meson_post_install.py
    patchShebangs meson_post_install.py
  '';

  nativeBuildInputs = [
    desktop-file-utils
    pkg-config
    meson
    ninja
    wrapGAppsHook4
    python3
    gobject-introspection
    gjs
    typescript
  ];

  buildInputs = [
    gtk4
    libadwaita
    gjs
    libgweather
    adwaita-icon-theme
    geoclue2
    gsettings-desktop-schemas
  ];

  passthru = {
    updateScript = gnome.updateScript {
      packageName = "gnome-weather";
    };
  };

  meta = {
    description = "Access current weather conditions and forecasts";
    homepage = "https://apps.gnome.org/Weather/";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.unix;
    mainProgram = "gnome-weather";
    teams = [ lib.teams.gnome ];
  };
})

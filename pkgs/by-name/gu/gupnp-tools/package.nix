{
  lib,
  stdenv,
  fetchurl,
  gettext,
  gnome,
  gssdp_1_6,
  gtk3,
  gtksourceview4,
  gupnp-av,
  gupnp_1_6,
  libsoup_3,
  meson,
  ninja,
  pkg-config,
  wrapGAppsHook3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gupnp-tools";
  version = "0.12.2";

  src = fetchurl {
    url = "mirror://gnome/sources/gupnp-tools/${lib.versions.majorMinor finalAttrs.version}/gupnp-tools-${finalAttrs.version}.tar.xz";
    sha256 = "TJLy0aPUVOwfX7Be8IyjTfnHQ69kyLWWXDWITUbLAFw=";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    gettext
    wrapGAppsHook3
  ];

  buildInputs = [
    gupnp_1_6
    libsoup_3
    gssdp_1_6
    gtk3
    gupnp-av
    gtksourceview4
  ];

  mesonFlags = [
    # Work around https://gitlab.gnome.org/GNOME/gupnp-tools/-/issues/29
    "-Dc_args=-Wno-error=deprecated-declarations"
  ];

  passthru = {
    updateScript = gnome.updateScript {
      packageName = "gupnp-tools";
      versionPolicy = "odd-unstable";
    };
  };

  meta = {
    description = "Set of utilities and demos to work with UPnP";
    homepage = "https://gitlab.gnome.org/GNOME/gupnp-tools";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.unix;
    teams = [ lib.teams.gnome ];
  };
})

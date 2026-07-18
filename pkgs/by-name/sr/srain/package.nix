{
  lib,
  stdenv,
  fetchFromGitHub,
  appstream-glib,
  dbus-glib,
  gettext,
  glib,
  glib-networking,
  gtk3,
  libayatana-appindicator,
  libconfig,
  libsecret,
  libsoup_3,
  meson,
  ninja,
  openssl,
  pkg-config,
  python3Packages,
  wrapGAppsHook3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "srain";
  version = "1.8.1";

  src = fetchFromGitHub {
    owner = "SrainApp";
    repo = "srain";
    rev = finalAttrs.version;
    hash = "sha256-F7TFCPTAU856403QNUUyf+10s/Yr4xDN/CarJNcUv4A=";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    gettext
    appstream-glib
    wrapGAppsHook3
    python3Packages.sphinx
  ];

  buildInputs = [
    gtk3
    glib
    glib-networking
    dbus-glib
    libconfig
    libsoup_3
    libsecret
    libayatana-appindicator
    openssl
  ];

  meta = {
    description = "Modern IRC client written in GTK";
    homepage = "https://srain.silverrainz.me";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ wineee ];
    platforms = lib.platforms.linux;
    mainProgram = "srain";
  };
})

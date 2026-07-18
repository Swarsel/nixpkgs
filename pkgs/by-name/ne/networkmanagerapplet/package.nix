{
  lib,
  stdenv,
  fetchurl,
  adwaita-icon-theme,
  gettext,
  glib,
  glib-networking,
  gnome,
  gobject-introspection,
  gsettings-desktop-schemas,
  gtk3,
  jansson,
  libayatana-appindicator,
  libgudev,
  libnma,
  libsecret,
  meson,
  modemmanager,
  networkmanager,
  ninja,
  pkg-config,
  polkit,
  python3,
  wrapGAppsHook3,
}:

stdenv.mkDerivation rec {
  pname = "network-manager-applet";
  version = "1.36.0";

  src = fetchurl {
    url = "mirror://gnome/sources/network-manager-applet/${lib.versions.majorMinor version}/network-manager-applet-${version}.tar.xz";
    sha256 = "sha256-qEcESH6jr+FIXEf7KrWYuPd59UCuDcvwocX4XmSn4lM=";
  };

  outputs = [
    "out"
    "man"
  ];

  postPatch = ''
    chmod +x meson_post_install.py # patchShebangs requires executable file
    patchShebangs meson_post_install.py

    # Prevent applet from autostarting in COSMIC, which has its own built-in network applet
    substituteInPlace nm-applet.desktop.in \
      --replace-fail "NotShowIn=KDE;GNOME;" "NotShowIn=KDE;GNOME;COSMIC;"
  '';

  nativeBuildInputs = [
    meson
    ninja
    gettext
    pkg-config
    wrapGAppsHook3
    gobject-introspection
    python3
  ];

  buildInputs = [
    libnma
    gtk3
    networkmanager
    libsecret
    gsettings-desktop-schemas
    polkit
    libgudev
    modemmanager
    jansson
    glib
    glib-networking
    libayatana-appindicator
    adwaita-icon-theme
  ];

  mesonFlags = [
    "-Dselinux=false"
    "-Dappindicator=yes"
  ];

  passthru = {
    updateScript = gnome.updateScript {
      attrPath = "networkmanagerapplet";
      packageName = pname;
      versionPolicy = "odd-unstable";
    };
  };

  meta = {
    description = "NetworkManager control applet for GNOME";
    homepage = "https://gitlab.gnome.org/GNOME/network-manager-applet/";
    license = lib.licenses.gpl2Plus;
    maintainers = [ ];
    platforms = lib.platforms.linux;
    mainProgram = "nm-applet";
  };
}

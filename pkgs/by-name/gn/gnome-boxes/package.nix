{
  lib,
  stdenv,
  fetchurl,
  acl,
  adwaita-icon-theme,
  cdrkit,
  cyrus_sasl,
  desktop-file-utils,
  gdbm,
  gettext,
  glib,
  glib-networking,
  gmp,
  gnome,
  gobject-introspection,
  gtk3,
  itstool,
  json-glib,
  libapparmor,
  libarchive,
  libcap,
  libcap_ng,
  libcdio,
  libgudev,
  libhandy,
  libosinfo,
  libportal-gtk3,
  librsvg,
  libsoup_3,
  libusb1,
  libvirt,
  libvirt-glib,
  libxml2,
  meson,
  mtools,
  ninja,
  numactl,
  pkg-config,
  qemu-utils,
  spice-gtk,
  spice-protocol,
  systemd,
  vala,
  vte,
  webkitgtk_4_1,
  wrapGAppsHook3,
  yajl,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gnome-boxes";
  version = "50.0";

  src = fetchurl {
    url = "mirror://gnome/sources/gnome-boxes/${lib.versions.major finalAttrs.version}/gnome-boxes-${finalAttrs.version}.tar.xz";
    hash = "sha256-/Wpd4Y0QkJRsqZ8fWjSqPhXcgYP2pyIm6NFQShNnLWc=";
  };

  patches = [
    # Fix path to libgovf-0.1.so in the gir file. We patch gobject-introspection to hardcode absolute paths but
    # our Meson patch will only pass the info when install_dir is absolute as well.
    ./fix-gir-lib-path.patch
  ];

  nativeBuildInputs = [
    gettext
    gobject-introspection
    itstool
    meson
    ninja
    pkg-config
    vala
    wrapGAppsHook3
    # For post install script
    glib
    gtk3
    desktop-file-utils
  ];

  buildInputs = [
    acl
    cyrus_sasl
    gdbm
    glib
    glib-networking
    gmp
    adwaita-icon-theme
    gtk3
    json-glib
    libapparmor
    libarchive
    libcap
    libcap_ng
    libgudev
    libhandy
    libosinfo
    librsvg
    libsoup_3
    libusb1
    libvirt
    libvirt-glib
    libxml2
    numactl
    spice-gtk
    spice-protocol
    systemd
    vte
    webkitgtk_4_1
    yajl
    libportal-gtk3
  ];

  doCheck = true;

  preFixup = ''
    gappsWrapperArgs+=(--prefix PATH : "${
      lib.makeBinPath [
        mtools
        cdrkit
        libcdio
        qemu-utils
      ]
    }")
  '';

  # Required for USB redirection PolicyKit rules file
  propagatedUserEnvPkgs = [ spice-gtk ];

  passthru = {
    updateScript = gnome.updateScript { packageName = "gnome-boxes"; };
  };

  meta = {
    description = "Simple GNOME 3 application to access remote or virtual systems";
    homepage = "https://apps.gnome.org/Boxes/";
    license = lib.licenses.lgpl2Plus;
    platforms = lib.platforms.linux;
    mainProgram = "gnome-boxes";
    teams = [ lib.teams.gnome ];
  };
})

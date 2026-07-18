{
  lib,
  stdenv,
  fetchurl,
  avahi,
  dbus,
  docbook_xml_dtd_42,
  docbook_xsl,
  fuse3,
  gcr_4,
  gettext,
  glib,
  glib-networking,
  gnome,
  gnome-online-accounts,
  gsettings-desktop-schemas,
  libarchive,
  libbluray,
  libcap,
  libcdio,
  libcdio-paranoia,
  libgcrypt,
  libgphoto2,
  libgudev,
  libimobiledevice,
  libmsgraph,
  libmtp,
  libnfs,
  libsecret,
  libsoup_3,
  libxml2,
  libxslt,
  meson,
  ninja,
  openssh,
  pkg-config,
  polkit,
  python3,
  replaceVars,
  samba,
  udisks,
  wrapGAppsHook3,
  gnomeSupport ? false,
  udevSupport ? stdenv.hostPlatform.isLinux,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gvfs";
  version = "1.60.1";

  src = fetchurl {
    url = "mirror://gnome/sources/gvfs/${lib.versions.majorMinor finalAttrs.version}/gvfs-${finalAttrs.version}.tar.xz";
    hash = "sha256-kOq6Mzq30xp/3q3kWVSlE8NmHM672aE4qrP7SB37nkA=";
  };

  patches = [
    (replaceVars ./hardcode-ssh-path.patch {
      ssh_program = "${lib.getBin openssh}/bin/ssh";
    })
  ];

  postPatch = ''
    patchShebangs test
  '';

  nativeBuildInputs = [
    meson
    ninja
    python3
    pkg-config
    gettext
    wrapGAppsHook3
    libxslt
    docbook_xsl
    docbook_xml_dtd_42
  ];

  buildInputs = [
    glib
    libgcrypt
    dbus
    libgphoto2
    avahi
    libarchive
    libimobiledevice
    libbluray
    libnfs
    libxml2
    gsettings-desktop-schemas
    libsoup_3
  ]
  ++ lib.optionals udevSupport [
    libgudev
    udisks
    fuse3
    libcdio
    samba
    libmtp
    libcap
    polkit
    libcdio-paranoia
  ]
  ++ lib.optionals gnomeSupport [
    gcr_4
    glib-networking # TLS support
    gnome-online-accounts
    libsecret
    libmsgraph
  ];

  mesonFlags = [
    "-Dsystemduserunitdir=${placeholder "out"}/lib/systemd/user"
    "-Dtmpfilesdir=no"
  ]
  ++ lib.optionals (!udevSupport) [
    "-Dgudev=false"
    "-Dudisks2=false"
    "-Dfuse=false"
    "-Dcdda=false"
    "-Dsmb=false"
    "-Dmtp=false"
    "-Dadmin=false"
    "-Dgphoto2=false"
    "-Dlibusb=false"
    "-Dlogind=false"
  ]
  ++ lib.optionals (!gnomeSupport) [
    "-Dgcr=false"
    "-Dgoa=false"
    "-Dkeyring=false"
    "-Donedrive=false"
  ]
  ++ lib.optionals (avahi == null) [
    "-Ddnssd=false"
  ]
  ++ lib.optionals (samba == null) [
    "-Dsmb=false"
  ];

  doCheck = false; # fails with "ModuleNotFoundError: No module named 'gi'"
  doInstallCheck = finalAttrs.finalPackage.doCheck;
  separateDebugInfo = true;

  passthru = {
    updateScript = gnome.updateScript {
      packageName = "gvfs";
      versionPolicy = "odd-unstable";
    };
  };

  meta = {
    description =
      "Virtual Filesystem support library" + lib.optionalString gnomeSupport " (full GNOME support)";

    license = lib.licenses.lgpl2Plus;
    platforms = lib.platforms.unix;
    teams = [ lib.teams.gnome ];
  };
})

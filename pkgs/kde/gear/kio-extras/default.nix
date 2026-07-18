{
  gperf,
  kio,
  libappimage,
  libimobiledevice,
  libmtp,
  libssh,
  libtirpc,
  libxcursor,
  mkKdeDerivation,
  openexr,
  pkg-config,
  qt5compat,
  qtsvg,
  samba,
  shared-mime-info,
  taglib,
}:
mkKdeDerivation {
  pname = "kio-extras";

  postInstall = ''
    substituteInPlace $out/share/dbus-1/services/org.kde.kmtpd5.service \
      --replace-fail Exec=$out/libexec/kf6/kiod6 Exec=${kio}/libexec/kf6/kiod6
  '';

  extraBuildInputs = [
    qt5compat
    qtsvg

    samba
    libssh
    libmtp
    libimobiledevice
    gperf
    libtirpc
    openexr
    taglib
    libappimage
    libxcursor
  ];

  extraNativeBuildInputs = [
    pkg-config
    gperf
    shared-mime-info
  ];
}

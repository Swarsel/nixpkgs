{
  libksysguard,
  libnl,
  lm_sensors,
  mkKdeDerivation,
  networkmanager-qt,
  pkg-config,
}:
mkKdeDerivation {
  pname = "ksystemstats";

  patches = [
    ./helper-path.patch
  ];

  extraBuildInputs = [
    networkmanager-qt
    lm_sensors
    libnl
  ];

  extraCmakeFlags = [
    "-DSYSTEMSTATS_DBUS_INTERFACE=${libksysguard}/share/dbus-1/interfaces/org.kde.ksystemstats1.xml"
  ];

  extraNativeBuildInputs = [ pkg-config ];
}

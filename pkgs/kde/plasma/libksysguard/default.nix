{
  kitemmodels,
  kquickcharts,
  libnl,
  libpcap,
  lm_sensors,
  mkKdeDerivation,
  qttools,
  qtwebchannel,
  qtwebengine,
}:
mkKdeDerivation {
  pname = "libksysguard";

  patches = [
    ./helper-path.patch
  ];

  extraBuildInputs = [
    qtwebchannel
    qtwebengine
    qttools
    libpcap
    libnl
    lm_sensors
  ];

  extraPropagatedBuildInputs = [
    kitemmodels
    kquickcharts
  ];
}

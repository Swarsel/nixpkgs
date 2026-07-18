{
  libical,
  mkKdeDerivation,
  pkg-config,
  qtlocation,
  qtpositioning,
  shared-mime-info,
}:
mkKdeDerivation {
  pname = "itinerary";

  extraBuildInputs = [
    qtlocation
    qtpositioning
    libical
  ];

  extraNativeBuildInputs = [
    pkg-config
    shared-mime-info
  ];

  meta.mainProgram = "itinerary";
}

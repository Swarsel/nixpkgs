{
  ddcutil,
  mkKdeDerivation,
  pkg-config,
  qtwayland,
}:
mkKdeDerivation {
  pname = "powerdevil";

  extraBuildInputs = [
    ddcutil
    qtwayland
  ];

  extraNativeBuildInputs = [ pkg-config ];
}

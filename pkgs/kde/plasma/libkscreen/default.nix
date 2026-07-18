{
  jq,
  mkKdeDerivation,
  qttools,
  qtwayland,
  wayland,
}:
mkKdeDerivation {
  pname = "libkscreen";
  extraBuildInputs = [ qtwayland ];

  extraNativeBuildInputs = [
    qttools
    qtwayland
    jq
    wayland
  ];

  meta.mainProgram = "kscreen-doctor";
}

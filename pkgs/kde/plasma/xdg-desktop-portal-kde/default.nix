{
  cups,
  mkKdeDerivation,
  pkg-config,
  qtwayland,
}:
mkKdeDerivation {
  pname = "xdg-desktop-portal-kde";

  extraBuildInputs = [
    qtwayland
    cups
  ];

  extraNativeBuildInputs = [ pkg-config ];
}

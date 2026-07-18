{
  flatpak,
  mkKdeDerivation,
  pkg-config,
  qtsvg,
}:
mkKdeDerivation {
  pname = "flatpak-kcm";

  extraBuildInputs = [
    flatpak
    qtsvg
  ];

  extraNativeBuildInputs = [ pkg-config ];
}

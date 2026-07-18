{
  mkKdeDerivation,
  pkg-config,
  qtmultimedia,
  qtsvg,
  wayland-protocols,
}:
mkKdeDerivation {
  pname = "kclock";

  extraBuildInputs = [
    qtsvg
    qtmultimedia

    wayland-protocols
  ];

  extraNativeBuildInputs = [ pkg-config ];
}

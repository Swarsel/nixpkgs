{
  fluidsynth,
  kirigami,
  mkKdeDerivation,
  pkg-config,
  qtdeclarative,
  qtsvg,
}:
mkKdeDerivation {
  pname = "minuet";

  extraBuildInputs = [
    qtdeclarative
    qtsvg
    kirigami
    fluidsynth
  ];

  extraNativeBuildInputs = [ pkg-config ];
  meta.mainProgram = "minuet";
}

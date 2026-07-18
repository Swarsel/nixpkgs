{
  hunspell,
  kddockwidgets,
  mkKdeDerivation,
  pkg-config,
}:
mkKdeDerivation {
  pname = "lokalize";

  extraBuildInputs = [
    kddockwidgets

    hunspell
  ];

  extraNativeBuildInputs = [ pkg-config ];
}

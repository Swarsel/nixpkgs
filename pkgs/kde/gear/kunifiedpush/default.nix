{
  kdeclarative,
  kpackage,
  mkKdeDerivation,
  qtwebsockets,
}:
mkKdeDerivation {
  pname = "kunifiedpush";

  extraBuildInputs = [
    qtwebsockets
    kdeclarative
    kpackage
  ];

  meta.mainProgram = "kunifiedpush-distributor";
}

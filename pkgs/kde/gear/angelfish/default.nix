{
  cargo,
  corrosion,
  mkKdeDerivation,
  qcoro,
  qtsvg,
  qtwebengine,
  rustPlatform,
  rustc,
  sources,
}:
mkKdeDerivation rec {
  inherit (sources.${pname}) version;
  pname = "angelfish";

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit pname version;
    src = sources.${pname};
    hash = "sha256-XbFbS8zNcrj8T2Av67f9JFAgheso9WW6flr3FabhL4I=";
  };

  extraBuildInputs = [
    qtsvg
    qtwebengine
    corrosion
    qcoro
  ];

  extraNativeBuildInputs = [
    rustPlatform.cargoSetupHook
    cargo
    rustc
  ];
}

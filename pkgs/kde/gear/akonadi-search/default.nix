{
  cargo,
  corrosion,
  mkKdeDerivation,
  rustPlatform,
  rustc,
  sources,
  xapian,
}:
mkKdeDerivation rec {
  inherit (sources.${pname}) version;
  pname = "akonadi-search";

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit pname version cargoRoot;
    src = sources.${pname};
    hash = "sha256-F9m2+WSrxjQgFDJ+//GCnMvzUD6734IGqnw7sRYIwTU=";
  };

  cargoRoot = "agent/rs/htmlparser";

  extraBuildInputs = [
    corrosion
    xapian
  ];

  extraNativeBuildInputs = [
    rustPlatform.cargoSetupHook
    cargo
    rustc
  ];
}

{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cargo,
  pytest,
  rustPlatform,
  rustc,
}:

buildPythonPackage rec {
  pname = "general-sam";
  version = "1.0.3";

  src = fetchFromGitHub {
    owner = "ModelTC";
    repo = "general-sam-py";
    rev = "v${version}";
    hash = "sha256-++6Z9Ocee4QFN1u0nK/g9uGdmB1UYnfHhhJj74zboCE=";
  };

  build-system = [
    cargo
    rustPlatform.cargoSetupHook
    rustPlatform.maturinBuildHook
    rustc
  ];

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit pname version src;
    hash = "sha256-8HHIM1Abz5KxnVphFFNJp6L3D6iPeoB7qVmxy11CUZs=";
  };

  optional-dependencies = {
    test = [
      pytest
    ];
  };

  pyproject = true;

  pythonImportsCheck = [
    "general_sam"
  ];

  meta = {
    description = "General suffix automaton implementation";
    homepage = "https://github.com/ModelTC/general-sam-py";

    license = with lib.licenses; [
      asl20
      mit
    ];

    maintainers = with lib.maintainers; [ BatteredBunny ];
  };
}

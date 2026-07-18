{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  numpy,
  rustPlatform,
  torch,
  triton,
}:

buildPythonPackage rec {
  pname = "kbnf";
  version = "0.4.2";

  src = fetchFromGitHub {
    owner = "Dan-wanna-M";
    repo = "kbnf";
    rev = "v${version}-python";
    hash = "sha256-reefuqS0eExky9qtxBTqwxnZgK8AWFfkrN+VL/lFLyg=";
  };

  # Manually unarchived from tarball from pypi
  postPatch = ''
    cp ${./Cargo.lock} Cargo.lock
  '';

  build-system = [
    rustPlatform.cargoSetupHook
    rustPlatform.maturinBuildHook
  ];

  cargoDeps = rustPlatform.importCargoLock {
    lockFile = ./Cargo.lock;
  };

  dependencies = [
    numpy
  ];

  optional-dependencies = {
    efficient_logits_mask = [
      triton
    ];

    torch = [
      torch
    ];
  };

  pyproject = true;

  pythonImportsCheck = [
    "kbnf"
  ];

  meta = {
    description = "Fast constrained decoding engine based on context free grammar";
    homepage = "https://pypi.org/project/kbnf/";

    license = with lib.licenses; [
      asl20
      mit
    ];

    maintainers = with lib.maintainers; [ BatteredBunny ];
  };
}

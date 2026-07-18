{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hypothesis,
  pytestCheckHook,
  rustPlatform,
}:

buildPythonPackage rec {
  pname = "fastuuid";
  version = "0.14.0";

  src = fetchFromGitHub {
    owner = "fastuuid";
    repo = "fastuuid";
    tag = version;
    hash = "sha256-EXyd94NR4P+FLPxDCa3LmwfpIHwGduoaPL0qULqcj00=";
  };

  postPatch = ''
    ln -s ${./Cargo.lock} Cargo.lock
  '';

  nativeBuildInputs = [
    rustPlatform.cargoSetupHook
    rustPlatform.maturinBuildHook
  ];

  nativeCheckInputs = [
    hypothesis
    pytestCheckHook
  ];

  cargoDeps = rustPlatform.importCargoLock {
    lockFile = ./Cargo.lock;
  };

  disabledTestPaths = [
    "tests/test_benchmarks.py"
  ];

  pyproject = true;
  pythonImportsCheck = [ "fastuuid" ];

  meta = {
    description = "CPython bindings to Rust's UUID library";
    homepage = "https://github.com/fastuuid/fastuuid";
    changelog = "https://github.com/fastuuid/fastuuid/releases/tag/${src.tag}";
    license = lib.licenses.bsd3;
    maintainers = [ lib.maintainers.dotlambda ];
  };
}

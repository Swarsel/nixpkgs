{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # dependencies
  niapy,
  numpy,
  # build-system
  poetry-core,
  # tests
  pytestCheckHook,
  pyyaml,
  scikit-learn,
  tomli,
  torch,
}:

buildPythonPackage (finalAttrs: {
  pname = "nianet";
  version = "1.1.4";

  src = fetchFromGitHub {
    owner = "SasoPavlic";
    repo = "nianet";
    tag = "version_${finalAttrs.version}";
    hash = "sha256-FZipl6Z9AfiL6WH0kvUn8bVxt8JLdDVlmTSqnyxe0nY=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pyyaml
    tomli
  ];

  __structuredAttrs = true;

  build-system = [
    poetry-core
  ];

  dependencies = [
    niapy
    numpy
    scikit-learn
    torch
  ];

  pyproject = true;
  pythonImportsCheck = [ "nianet" ];

  pythonRelaxDeps = [
    "numpy"
    "torch"
  ];

  meta = {
    description = "Designing and constructing neural network topologies using nature-inspired algorithms";
    homepage = "https://github.com/SasoPavlic/NiaNet";
    changelog = "https://github.com/SasoPavlic/NiaNet/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ firefly-cpp ];
  };
})

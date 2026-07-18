{
  lib,
  fetchFromGitHub,
  # dependencies
  boltons,
  buildPythonPackage,
  numpy,
  # tests
  pytest7CheckHook,
  scipy,
  # build-system
  setuptools,
  torch,
  trampoline,
}:

buildPythonPackage rec {
  pname = "torchsde";
  version = "0.2.6";

  src = fetchFromGitHub {
    owner = "google-research";
    repo = "torchsde";
    tag = "v${version}";
    hash = "sha256-D0p2tL/VvkouXrXfRhMuCq8wMtzeoBTppWEG5vM1qCo=";
  };

  postPatch = ''
    substituteInPlace setup.py \
      --replace "numpy==1.19.*" "numpy" \
      --replace "scipy==1.5.*" "scipy"
  '';

  nativeBuildInputs = [ setuptools ];

  propagatedBuildInputs = [
    boltons
    numpy
    scipy
    torch
    trampoline
  ];

  nativeCheckInputs = [ pytest7CheckHook ];

  disabledTests = [
    # RuntimeError: a view of a leaf Variable that requires grad is being used in an in-place operation.
    "test_adjoint"
  ];

  pyproject = true;
  pythonImportsCheck = [ "torchsde" ];

  meta = {
    description = "Differentiable SDE solvers with GPU support and efficient sensitivity analysis";
    homepage = "https://github.com/google-research/torchsde";
    changelog = "https://github.com/google-research/torchsde/releases/tag/v${version}";
    license = lib.licenses.asl20;
    teams = [ lib.teams.tts ];
  };
}

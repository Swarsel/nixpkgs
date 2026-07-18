{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  packaging,
  primepy,
  setuptools,
  torch,
  torchaudio,
}:

buildPythonPackage rec {
  pname = "torch-pitch-shift";
  version = "1.2.5";

  src = fetchFromGitHub {
    owner = "KentoNishi";
    repo = "torch-pitch-shift";
    tag = "v${version}";
    hash = "sha256-QuDz9IpmBdzfMjwAuG2Ln0x2OL/w3RVd/EfO4Ws78dw=";
  };

  # Module has no tests
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    packaging
    primepy
    torch
    torchaudio
  ];

  pyproject = true;
  pythonImportsCheck = [ "torch_pitch_shift" ];
  pythonRelaxDeps = [ "torchaudio" ];

  meta = {
    description = "Pitch-shift audio clips quickly with PyTorch (CUDA supported)! Additional utilities for searching efficient transformations are included";
    homepage = "https://github.com/KentoNishi/torch-pitch-shift";
    changelog = "https://github.com/KentoNishi/torch-pitch-shift/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ matthewcroughan ];
  };
}

{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # dependencies
  librosa,
  # tests
  pytestCheckHook,
  resampy,
  scipy,
  # build-system
  setuptools,
  torch,
  torchaudio,
  torchcodec,
  tqdm,
}:

buildPythonPackage {
  pname = "torchcrepe";
  version = "0.0.24";

  src = fetchFromGitHub {
    owner = "maxrmorrison";
    repo = "torchcrepe";
    # No releases: https://github.com/maxrmorrison/torchcrepe/commit/19e2ec3d494c0797a5ff2a11408ec5838fba6681
    rev = "19e2ec3d494c0797a5ff2a11408ec5838fba6681";
    hash = "sha256-w2T8D3ATCHVBCBhMdLSYdV0yb9vUYwZLz+B2X2gteEU=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];

  dependencies = [
    librosa
    resampy
    scipy
    torch
    torchaudio
    torchcodec
    tqdm
  ];

  pyproject = true;
  pythonImportsCheck = [ "torchcrepe" ];

  meta = {
    description = "Pytorch implementation of the CREPE pitch tracker";
    homepage = "https://github.com/maxrmorrison/torchcrepe";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ derdennisop ];
  };
}

{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  joblib,
  matplotlib,
  numpy,
  pytestCheckHook,
  scipy,
  setuptools,
  torch,
  tqdm,
}:

buildPythonPackage rec {
  pname = "noisereduce";
  version = "3.0.3";

  src = fetchFromGitHub {
    owner = "timsainb";
    repo = "noisereduce";
    tag = "v${version}";
    hash = "sha256-CMXbl+9L01rtsD8BZ3nNomacsChy/1EGdUdWz7Ytbjk=";
  };

  nativeCheckInputs = [ pytestCheckHook ] ++ lib.concatAttrValues optional-dependencies;
  build-system = [ setuptools ];

  dependencies = [
    joblib
    matplotlib
    numpy
    scipy
    tqdm
  ];

  optional-dependencies = {
    PyTorch = [ torch ];
  };

  pyproject = true;
  pythonImportsCheck = [ "noisereduce" ];

  meta = {
    description = "Noise reduction using spectral gating (speech, bioacoustics, audio, time-domain signals";
    homepage = "https://github.com/timsainb/noisereduce";
    changelog = "https://github.com/timsainb/noisereduce/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
}

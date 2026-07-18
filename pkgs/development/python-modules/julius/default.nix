{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
  torch,
  wheel,
}:

buildPythonPackage rec {
  pname = "julius";
  version = "0.2.7";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-PA9fUwbX1gFvzJUZaydMrm8H4slZbu0xTk52QVVPuwg=";
  };

  nativeBuildInputs = [
    setuptools
    wheel
  ];

  propagatedBuildInputs = [ torch ];
  pyproject = true;
  pythonImportsCheck = [ "julius" ];

  meta = {
    description = "Nice DSP sweets: resampling, FFT Convolutions. All with PyTorch, differentiable and with CUDA support";
    homepage = "https://pypi.org/project/julius/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ matthewcroughan ];
  };
}

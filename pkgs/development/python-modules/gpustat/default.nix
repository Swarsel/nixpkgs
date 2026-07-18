{
  lib,
  blessed,
  buildPythonPackage,
  fetchPypi,
  mockito,
  nvidia-ml-py,
  psutil,
  pytestCheckHook,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "gpustat";
  version = "1.1.1";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-wY0+1VGPwWMAxC1pTevHCuuzvlXK6R8dtk1jtfqK+dg=";
  };

  nativeBuildInputs = [
    setuptools-scm
  ];

  propagatedBuildInputs = [
    blessed
    nvidia-ml-py
    psutil
  ];

  nativeCheckInputs = [
    mockito
    pytestCheckHook
  ];

  format = "setuptools";
  pythonImportsCheck = [ "gpustat" ];
  pythonRelaxDeps = [ "nvidia-ml-py" ];

  meta = {
    description = "Simple command-line utility for querying and monitoring GPU status";
    homepage = "https://github.com/wookayin/gpustat";
    changelog = "https://github.com/wookayin/gpustat/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ billhuang ];
    mainProgram = "gpustat";
  };
}

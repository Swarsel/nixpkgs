{
  lib,
  buildPythonPackage,
  fetchPypi,
  git-versioner,
  pip,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "pip-system-certs";
  version = "5.3";

  src = fetchPypi {
    inherit version;
    hash = "sha256-Gci/mVe8zn1pxNvC0LLvE94ZhNU/UKWQEubbutCvZ8Y=";
    pname = "pip_system_certs";
  };

  build-system = [
    setuptools-scm
    git-versioner
  ];

  dependencies = [ pip ];
  pyproject = true;

  pythonImportsCheck = [
    "pip_system_certs.wrapt_requests"
    "pip_system_certs.bootstrap"
  ];

  meta = {
    description = "Live patches pip and requests to use system certs by default";
    homepage = "https://gitlab.com/alelec/pip-system-certs";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ slotThe ];
  };
}

{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  python,
  requests-mock,
  setuptools,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "remotezip2";
  version = "0.0.2";

  src = fetchFromGitHub {
    owner = "doronz88";
    repo = "python-remotezip2";
    tag = "v${version}";
    hash = "sha256-UyfAoe9pXCGLGPIE2LSLvnIaju+nXt3s7ddGlpmJGUg=";
  };

  nativeCheckInputs = [
    requests-mock
  ];

  checkPhase = ''
    runHook preCheck

    ${python.interpreter} test_remotezip2.py

    runHook postCheck
  '';

  build-system = [
    setuptools
    setuptools-scm
  ];

  pyproject = true;
  pythonImportsCheck = [ "remotezip2" ];

  meta = {
    description = "Access zip file content hosted remotely without downloading the full file";
    homepage = "https://github.com/doronz88/python-remotezip2";
    changelog = "https://github.com/doronz88/python-remotezip2/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.dotlambda ];
  };
}

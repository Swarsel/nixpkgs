{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  colander,
  pyramid,
  pytest-cache,
  pytestCheckHook,
  setuptools,
  setuptools-scm,
  webtest,
}:

buildPythonPackage rec {
  pname = "cornice";
  version = "6.1.0";

  src = fetchFromGitHub {
    owner = "Cornices";
    repo = "cornice";
    rev = version;
    hash = "sha256-jAf8unDPpr/ZAWkb9LhOW4URjwcRnaYVUKmfnYBStTg=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pytest-cache
    webtest
    colander
  ];

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [ pyramid ];
  pyproject = true;
  pythonImportsCheck = [ "cornice" ];

  meta = {
    description = "Build Web Services with Pyramid";
    homepage = "https://github.com/mozilla-services/cornice";
    license = lib.licenses.mpl20;
    maintainers = [ ];
  };
}

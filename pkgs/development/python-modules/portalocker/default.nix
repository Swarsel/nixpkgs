{
  lib,
  buildPythonPackage,
  fetchPypi,
  # tests
  pygments,
  pytest-cov-stub,
  pytest-rerunfailures,
  pytest-timeout,
  pytestCheckHook,
  # dependencies
  redis,
  # build-system
  setuptools,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "portalocker";
  version = "3.2.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-HzAClWpUqMNzBYbFx3vxj65BSeB+rxwp/D+vTVo/iaw=";
  };

  nativeBuildInputs = [
    setuptools
    setuptools-scm
  ];

  propagatedBuildInputs = [ redis ];

  nativeCheckInputs = [
    pygments
    pytest-cov-stub
    pytest-rerunfailures
    pytest-timeout
    pytestCheckHook
  ];

  pyproject = true;
  pythonImportsCheck = [ "portalocker" ];

  meta = {
    description = "Library to provide an easy API to file locking";
    homepage = "https://github.com/WoLpH/portalocker";
    changelog = "https://github.com/wolph/portalocker/releases/tag/v${version}";
    license = lib.licenses.psfl;
    maintainers = [ ];
  };
}

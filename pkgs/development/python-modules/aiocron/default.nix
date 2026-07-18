{
  lib,
  buildPythonPackage,
  cronsim,
  fetchPypi,
  pytest-cov-stub,
  pytest-xdist,
  pytestCheckHook,
  python,
  python-dateutil,
  setuptools,
  tzlocal,
}:

buildPythonPackage rec {
  pname = "aiocron";
  version = "2.1";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-G7ZaNq7hN+iDNZJ4OVbgx9xHi8PpJz/ChB1dDGBF5NI=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pytest-cov-stub
    pytest-xdist
    tzlocal
  ];

  postInstall = ''
    rm -rf $out/${python.sitePackages}/tests
  '';

  build-system = [ setuptools ];

  dependencies = [
    cronsim
    python-dateutil
    tzlocal
  ];

  pyproject = true;
  pythonImportsCheck = [ "aiocron" ];

  meta = {
    description = "Crontabs for asyncio";
    homepage = "https://github.com/gawel/aiocron/";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.starcraft66 ];
  };
}

{
  buildPythonPackage,
  pytest-asyncio,
  pytestCheckHook,
  sanic-testing,
  setuptools,
}:

buildPythonPackage {
  inherit (sanic-testing) version;
  pname = "sanic-testing-tests";
  src = sanic-testing.testsout;

  nativeCheckInputs = [
    pytest-asyncio
    pytestCheckHook
    sanic-testing
    setuptools
  ];

  dontBuild = true;
  dontInstall = true;
  pyproject = false;
  pythonImportsCheck = [ "sanic_testing" ];
}

{
  buildPythonPackage,
  flaky,
  hypothesis,
  pytest-asyncio,
  pytest-trio,
  pytestCheckHook,
}:

buildPythonPackage {
  inherit (pytest-asyncio) version;
  pname = "pytest-asyncio-tests";
  src = pytest-asyncio.testout;
  propagatedBuildInputs = [ pytest-asyncio ];

  nativeCheckInputs = [
    flaky
    hypothesis
    pytest-trio
    pytestCheckHook
  ];

  dontBuild = true;
  dontInstall = true;
  pyproject = false;
}

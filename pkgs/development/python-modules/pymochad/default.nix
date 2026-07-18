{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  fixtures,
  mock,
  pbr,
  pytestCheckHook,
  setuptools,
  six,
  testtools,
}:

buildPythonPackage rec {
  pname = "pymochad";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "mtreinish";
    repo = "pymochad";
    tag = version;
    hash = "sha256-nwh97sbYkt4F/u02zTDemWEztSco27oJCemd6kTnCMk=";
  };

  env.PBR_VERSION = version;

  nativeCheckInputs = [
    pytestCheckHook
    mock
    fixtures
    testtools
  ];

  build-system = [
    pbr
    setuptools
  ];

  dependencies = [
    six
  ];

  pyproject = true;

  pythonImportsCheck = [
    "pymochad"
  ];

  meta = {
    description = "Python library for sending commands to the mochad TCP gateway daemon for the X10 CMA15A controller";
    homepage = "https://github.com/mtreinish/pymochad";
    license = lib.licenses.gpl3Only;
    maintainers = [ lib.maintainers.jamiemagee ];
  };
}

{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  mock,
  pytestCheckHook,
  requests,
  responses,
  setuptools_80,
  urllib3,
}:

buildPythonPackage rec {
  pname = "tank-utility";
  version = "1.5.0";

  src = fetchFromGitHub {
    owner = "krismolendyke";
    repo = "tank-utility";
    tag = version;
    hash = "sha256-h9y3X+FSzSFt+bd/chz+x0nocHaKZ8DvreMxAYMs8/E=";
  };

  nativeCheckInputs = [
    mock
    pytestCheckHook
    responses
  ];

  build-system = [ setuptools_80 ];

  dependencies = [
    requests
    urllib3
  ];

  pyproject = true;
  pythonImportsCheck = [ "tank_utility" ];

  meta = {
    description = "Library for the Tank Utility API";
    homepage = "https://github.com/krismolendyke/tank-utility";
    changelog = "https://github.com/krismolendyke/tank-utility/blob/${version}/HISTORY.rst";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "tank-utility";
  };
}

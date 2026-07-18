{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hatch-vcs,
  hatchling,
  mockito,
  pytest,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "pytest-mockito";
  version = "0.0.6.post1";

  src = fetchFromGitHub {
    owner = "kaste";
    repo = "pytest-mockito";
    rev = version;
    hash = "sha256-zlErrgVeeVNojZfYYACRx/4sDWaub7EN1bCr4IhtMPg=";
  };

  buildInputs = [ pytest ];
  nativeCheckInputs = [ pytestCheckHook ];

  build-system = [
    hatch-vcs
    hatchling
  ];

  dependencies = [ mockito ];
  pyproject = true;
  pythonImportsCheck = [ "pytest_mockito" ];

  meta = {
    description = "Base fixtures for mockito";
    homepage = "https://github.com/kaste/pytest-mockito";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}

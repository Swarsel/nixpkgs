{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  flit-core,
  freezegun,
  pytest,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "pytest-freezer";
  version = "0.4.9";

  src = fetchFromGitHub {
    owner = "pytest-dev";
    repo = "pytest-freezer";
    tag = version;
    hash = "sha256-WJGwkON/RAiUiGzNkeqjzch4CEr6mPXij5dqz1ncRXs=";
  };

  buildInputs = [ pytest ];
  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ flit-core ];
  dependencies = [ freezegun ];
  pyproject = true;
  pythonImportsCheck = [ "pytest_freezer" ];

  meta = {
    description = "Pytest plugin providing a fixture interface for spulec/freezegun";
    homepage = "https://github.com/pytest-dev/pytest-freezer";
    changelog = "https://github.com/pytest-dev/pytest-freezer/releases/tag/${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
}

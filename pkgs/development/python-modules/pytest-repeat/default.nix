{
  lib,
  buildPythonPackage,
  fetchPypi,
  hatch-vcs,
  hatchling,
  pytest,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "pytest-repeat";
  version = "0.9.4";

  src = fetchPypi {
    inherit version;
    hash = "sha256-2SrBTfqm/8/mkX5dFvDJvII4DBNbA8Kl9BLSY38iRIU=";
    pname = "pytest_repeat";
  };

  buildInputs = [ pytest ];
  nativeCheckInputs = [ pytestCheckHook ];

  build-system = [
    hatchling
    hatch-vcs
  ];

  pyproject = true;
  pythonImportsCheck = [ "pytest_repeat" ];

  meta = {
    description = "Pytest plugin for repeating tests";
    homepage = "https://github.com/pytest-dev/pytest-repeat";
    changelog = "https://github.com/pytest-dev/pytest-repeat/blob/v${version}/CHANGES.rst";
    license = lib.licenses.mpl20;
    maintainers = [ ];
  };
}

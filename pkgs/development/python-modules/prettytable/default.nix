{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # build-system
  hatch-vcs,
  hatchling,
  # tests
  pytest-lazy-fixtures,
  pytestCheckHook,
  # dependencies
  wcwidth,
}:

buildPythonPackage rec {
  pname = "prettytable";
  version = "3.17.0";

  src = fetchFromGitHub {
    owner = "jazzband";
    repo = "prettytable";
    tag = version;
    hash = "sha256-MvKa6M2kfD3rUl+kxsD87ieBzmDtahoMQJUNWsofCBc=";
  };

  nativeCheckInputs = [
    pytest-lazy-fixtures
    pytestCheckHook
  ];

  build-system = [
    hatch-vcs
    hatchling
  ];

  dependencies = [ wcwidth ];
  pyproject = true;
  pythonImportsCheck = [ "prettytable" ];

  meta = {
    description = "Display tabular data in a visually appealing ASCII table format";
    homepage = "https://github.com/jazzband/prettytable";
    changelog = "https://github.com/jazzband/prettytable/releases/tag/${version}";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ GaetanLepage ];
  };
}

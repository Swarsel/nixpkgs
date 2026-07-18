{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hatchling,
  pytestCheckHook,
}:
buildPythonPackage rec {
  pname = "dataclass-csv";
  version = "1.4.1";

  src = fetchFromGitHub {
    owner = "dfurtado";
    repo = "dataclass-csv";
    tag = version;
    hash = "sha256-hDnuPg5xniybR2J91KnJxSlOI+dWzUPQJtYKfqsNCvw=";
  };

  nativeCheckInputs = [
    pytestCheckHook
  ];

  build-system = [
    hatchling
  ];

  pyproject = true;
  pythonImportsCheck = [ "dataclass_csv" ];

  meta = {
    description = "Map CSV data into dataclasses";
    homepage = "https://github.com/dfurtado/dataclass-csv";
    changelog = "https://github.com/dfurtado/dataclass-csv/releases/tag/${version}";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ theobori ];
  };
}

{
  lib,
  fetchFromGitLab,
  buildPythonPackage,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "python-sql";
  version = "1.7.0";

  src = fetchFromGitLab {
    owner = "tryton";
    repo = "python-sql";
    tag = version;
    hash = "sha256-JhMJEng6QftWBmJIC2pYlf9fkHHmSd3k0tSwr35MmVQ=";
    domain = "foss.heptapod.net";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "sql" ];

  meta = {
    description = "Library to write SQL queries in a pythonic way";
    homepage = "https://foss.heptapod.net/tryton/python-sql";
    changelog = "https://foss.heptapod.net/tryton/python-sql/-/blob/${src.tag}/CHANGELOG";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ johbo ];
  };
}

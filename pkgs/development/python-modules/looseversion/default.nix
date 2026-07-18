{
  lib,
  buildPythonPackage,
  fetchPypi,
  hatchling,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "looseversion";
  version = "1.3.0";

  src = fetchPypi {
    inherit version pname;
    hash = "sha256-695l8/a7lTGoEBbG/vPrlaYRga3Ee3+UnpwOpHkRZp4=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ hatchling ];
  enabledTestPaths = [ "tests.py" ];
  pyproject = true;
  pythonImportsCheck = [ "looseversion" ];

  meta = {
    description = "Version numbering for anarchists and software realists";
    homepage = "https://github.com/effigies/looseversion";
    changelog = "https://github.com/effigies/looseversion/blob/${version}/CHANGES.md";
    license = lib.licenses.psfl;
    maintainers = with lib.maintainers; [ pelme ];
  };
}

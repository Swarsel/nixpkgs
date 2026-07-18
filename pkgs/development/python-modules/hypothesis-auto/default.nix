{
  lib,
  buildPythonPackage,
  fetchPypi,
  hypothesis,
  poetry-core,
  pydantic,
  pytest,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "hypothesis-auto";
  version = "1.1.5";

  src = fetchPypi {
    inherit version;
    hash = "sha256-U0vcOB9jXmUV5v2IwybVu2arY1FpPnKkP7m2kbD1kRw=";
    pname = "hypothesis_auto";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ poetry-core ];

  dependencies = [
    hypothesis
    pydantic
  ];

  optional-dependencies = {
    pytest = [ pytest ];
  };

  pyproject = true;
  pythonImportsCheck = [ "hypothesis_auto" ];

  pythonRelaxDeps = [
    "hypothesis"
    "pydantic"
  ];

  meta = {
    description = "Enables fully automatic tests for type annotated functions";
    homepage = "https://github.com/timothycrosley/hypothesis-auto/";
    changelog = "https://github.com/timothycrosley/hypothesis-auto/blob/master/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}

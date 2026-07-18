{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  jsonpatch,
  jsonschema,
  poetry-core,
  pytest-cov-stub,
  pytestCheckHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "warlock";
  version = "2.0.1";

  src = fetchFromGitHub {
    owner = "bcwaldon";
    repo = "warlock";
    tag = finalAttrs.version;
    hash = "sha256-HOCLzFYmOL/tCXT+NO/tCZuVXVowNEPP3g33ZYg4+6Q=";
  };

  nativeBuildInputs = [ poetry-core ];

  propagatedBuildInputs = [
    jsonpatch
    jsonschema
  ];

  nativeCheckInputs = [
    pytestCheckHook
    pytest-cov-stub
  ];

  disabledTests = [
    # https://github.com/bcwaldon/warlock/issues/64
    "test_recursive_models"
  ];

  pyproject = true;
  pythonImportsCheck = [ "warlock" ];

  meta = {
    description = "Python object model built on JSON schema and JSON patch";
    homepage = "https://github.com/bcwaldon/warlock";
    license = lib.licenses.asl20;
    maintainers = [ ];
  };
})

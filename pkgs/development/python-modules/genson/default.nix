{
  lib,
  buildPythonPackage,
  fetchPypi,
  jsonschema,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "genson";
  version = "1.3.0";

  # Using Python repository source due to missing genson.schema in setup tools.
  src = fetchPypi {
    inherit pname version;
    hash = "sha256-4C25rC4/0p5ltShvcTV2LizYqYZTfAdbBvxfFRcwjjc=";
  };

  nativeCheckInputs = [
    jsonschema
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  disabledTests = [
    "test_no_input"
  ];

  pyproject = true;
  pythonImportsCheck = [ "genson" ];

  meta = {
    description = "GenSON a JSON Schema generator built in Python";
    homepage = "https://github.com/wolverdude/GenSON";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ tochiaha ];
    mainProgram = "genson";
  };
}

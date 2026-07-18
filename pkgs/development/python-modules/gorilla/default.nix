{
  lib,
  buildPythonPackage,
  fetchPypi,
  pytestCheckHook,
  pythonAtLeast,
  setuptools,
}:

buildPythonPackage rec {
  pname = "gorilla";
  version = "0.4.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-AFq4hTsDcWKnx3u4JGBMbggYeO4DwJrQHvQXRIVgGdM=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];
  disabledTests = lib.optionals (pythonAtLeast "3.12") [ "test_find_patches_2" ];
  pyproject = true;
  pythonImportsCheck = [ "gorilla" ];

  meta = {
    description = "Convenient approach to monkey patching";
    homepage = "https://github.com/christophercrouzet/gorilla";
    changelog = "https://github.com/christophercrouzet/gorilla/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}

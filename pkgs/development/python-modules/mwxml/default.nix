{
  lib,
  stdenv,
  buildPythonPackage,
  fetchPypi,
  # dependencies
  jsonschema,
  mwcli,
  mwtypes,
  # tests
  pytestCheckHook,
  pythonAtLeast,
  # build-system
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "mwxml";
  version = "0.3.8";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-yiIyqX6pMem7JPhbVKSRBYwjwHRXY3LnESRq+scGFuA=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];

  dependencies = [
    jsonschema
    mwcli
    mwtypes
  ];

  disabledTests =
    lib.optionals (pythonAtLeast "3.14") [
      # _pickle.PicklingError: Can't pickle local object <function map.<locals>.process_path at 0x7ffff580f480>
      "test_complex_error_handler"
    ]
    ++ lib.optionals stdenv.hostPlatform.isDarwin [
      # AttributeError: Can't get local object 'map.<locals>.process_path'
      "test_complex_error_handler"
    ];

  pyproject = true;
  pythonImportsCheck = [ "mwxml" ];

  meta = {
    description = "Set of utilities for processing MediaWiki XML dump data";
    homepage = "https://github.com/mediawiki-utilities/python-mwxml";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ GaetanLepage ];
    mainProgram = "mwxml";
  };
})

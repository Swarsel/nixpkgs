{
  lib,
  buildPythonPackage,
  fetchPypi,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "demjson3";
  version = "3.0.6";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-N8g7DG6wjSXe/IjfCipIddWKeAmpZQvW7uev2AU826w=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  __structuredAttrs = true;
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "demjson3" ];

  meta = {
    description = "Encoder/decoder and lint/validator for JSON (JavaScript Object Notation)";
    homepage = "https://github.com/nielstron/demjson3/";
    license = lib.licenses.lgpl3Plus;
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "jsonlint";
  };
})

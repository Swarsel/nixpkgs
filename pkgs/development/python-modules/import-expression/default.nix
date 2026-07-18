{
  lib,
  buildPythonPackage,
  fetchPypi,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "import-expression";
  version = "2.2.1.post1";

  src = fetchPypi {
    inherit version;
    hash = "sha256-HIMb8mvvft82qXs0xoe5Yuer4GEWxm8A4U+aMhhiPU8=";
    pname = "import_expression";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];
  enabledTestPaths = [ "tests.py" ];
  pyproject = true;
  pythonImportsCheck = [ "import_expression" ];

  meta = {
    description = "Transpiles a superset of python to allow easy inline imports";
    homepage = "https://github.com/ioistired/import-expression-parser";
    changelog = "https://github.com/ioistired/import-expression/releases/tag/v${version}";

    license = with lib.licenses; [
      mit
      psfl
    ];

    maintainers = [ ];
    mainProgram = "import-expression";
  };
}

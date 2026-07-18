{
  lib,
  buildPythonPackage,
  fetchPypi,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "xlrd";
  version = "2.0.2";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-CLXiXeWPIc5x3H2zs7gQbB+ndvMCTFTkW0WzdOiSNMk=";
  };

  # No tests in archive
  doCheck = false;
  nativeCheckInputs = [ pytestCheckHook ];
  __structuredAttrs = true;
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "xlrd" ];

  meta = {
    description = "Library for developers to extract data from Microsoft Excel (tm) spreadsheet files";
    homepage = "https://www.python-excel.org/";
    license = lib.licenses.bsd0;
    mainProgram = "runxlrd.py";
  };
})

{
  lib,
  buildPythonPackage,
  fetchPypi,
  fetchpatch,
  lxml,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "tableaudocumentapi";
  version = "0.11";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-g6V1UBf+P21FcZkR3PHoUmdmrQwEvjdd1VKhvNmvOys=";
  };

  patches = [
    # distutils has been removed since python 3.12
    # see https://github.com/tableau/document-api-python/pull/255
    (fetchpatch {
      hash = "sha256-mjIF9iP1BQXvqkS0jYNTm8otkhSKLj2b2iHSMZ2K0iI=";
      name = "no-distutils.patch";
      url = "https://github.com/tableau/document-api-python/pull/255/commits/59280bbe073060d1249e6404e11303ed6faa84f6.patch";
    })
  ];

  # ModuleNotFoundError: No module named 'test.assets'
  doCheck = false;
  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];
  dependencies = [ lxml ];
  pyproject = true;
  pythonImportsCheck = [ "tableaudocumentapi" ];

  meta = {
    description = "Python module for working with Tableau files";
    homepage = "https://github.com/tableau/document-api-python";
    changelog = "https://github.com/tableau/document-api-python/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}

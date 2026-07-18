{
  lib,
  buildPythonPackage,
  fetchPypi,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "smmap";
  version = "6.0.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-jXkCjqbMEx2l6rCZpdlamY1DxneZVv/+O0VQQJEQdto=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "smmap" ];

  meta = {
    description = "Pure python implementation of a sliding window memory map manager";
    homepage = "https://github.com/gitpython-developers/smmap";
    license = lib.licenses.bsd3;
    maintainers = [ ];
  };
}

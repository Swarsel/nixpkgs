{
  lib,
  buildPythonPackage,
  fetchPypi,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "lazy";
  version = "2.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-+S7A0y3WvRFd3sTjMjRz68C2gq1Yxqynjr/Z5tGqV3c=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "lazy" ];

  meta = {
    description = "Lazy attributes for Python objects";
    homepage = "https://github.com/stefanholek/lazy";
    license = lib.licenses.bsd2;
  };
}

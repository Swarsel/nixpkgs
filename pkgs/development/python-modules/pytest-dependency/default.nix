{
  lib,
  buildPythonPackage,
  fetchPypi,
  pytest,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "pytest-dependency";
  version = "0.6.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-k0sOajnZWZUGLBk/fq7tio/6Bv8bzvS2Kw3HSnCLrME=";
  };

  nativeBuildInputs = [ setuptools ];
  buildInputs = [ pytest ];
  nativeCheckInputs = [ pytestCheckHook ];
  pyproject = true;
  pythonImportsCheck = [ "pytest_dependency" ];

  meta = {
    description = "Manage dependencies of tests";
    homepage = "https://github.com/RKrahl/pytest-dependency";
    changelog = "https://github.com/RKrahl/pytest-dependency/blob/${version}/CHANGES.rst";
    license = lib.licenses.asl20;
    maintainers = [ ];
  };
}

{
  lib,
  buildPythonPackage,
  fetchPypi,
  more-itertools,
  pytestCheckHook,
  setuptools,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "jaraco-stream";
  version = "3.0.4";

  src = fetchPypi {
    inherit version;
    sha256 = "sha256-4rxQKOch7SzIUrluyaM/K3Zk6bLb+H7vvmF9EmZBk0s=";
    pname = "jaraco_stream";
  };

  propagatedBuildInputs = [ more-itertools ];
  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools-scm ];
  pyproject = true;
  pythonImportsCheck = [ "jaraco.stream" ];
  pythonNamespaces = [ "jaraco" ];

  meta = {
    description = "Module with routines for handling streaming data";
    homepage = "https://github.com/jaraco/jaraco.stream";
    changelog = "https://github.com/jaraco/jaraco.stream/blob/v${version}/NEWS.rst";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}

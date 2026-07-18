{
  lib,
  buildPythonPackage,
  fetchPypi,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "lazr-uri";
  version = "1.0.8";

  src = fetchPypi {
    inherit version;
    hash = "sha256-DkWFTrImh5WN+4B2Vf9+CVsXZb5kniTMxYGTTQM307Q=";
    pname = "lazr_uri";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];
  dependencies = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "lazr.uri" ];
  pythonNamespaces = [ "lazr" ];

  meta = {
    description = "Self-contained, easily reusable library for parsing, manipulating";
    homepage = "https://launchpad.net/lazr.uri";
    changelog = "https://git.launchpad.net/lazr.uri/tree/NEWS.rst?h=${version}";
    license = lib.licenses.lgpl3Only;
    maintainers = [ ];
  };
}

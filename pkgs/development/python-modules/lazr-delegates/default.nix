{
  lib,
  buildPythonPackage,
  fetchPypi,
  pytestCheckHook,
  setuptools,
  zope-interface,
}:

buildPythonPackage rec {
  pname = "lazr-delegates";
  version = "2.1.1";

  src = fetchPypi {
    inherit version;
    hash = "sha256-rs6yYW5Rtz8yf78SxOwrfXZwy4IL1eT2hRIV+3lsAtw=";
    pname = "lazr_delegates";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];
  dependencies = [ zope-interface ];
  pyproject = true;
  pythonImportsCheck = [ "lazr.delegates" ];
  pythonNamespaces = [ "lazr" ];

  meta = {
    description = "Easily write objects that delegate behavior";
    homepage = "https://launchpad.net/lazr.delegates";
    changelog = "https://git.launchpad.net/lazr.delegates/tree/NEWS.rst?h=${version}";
    license = lib.licenses.lgpl3Only;
  };
}

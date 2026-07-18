{
  lib,
  buildPythonPackage,
  fetchgit,
  lazr-delegates,
  pytestCheckHook,
  setuptools,
  zope-interface,
}:

buildPythonPackage rec {
  pname = "lazr-config";
  version = "3.1";

  src = fetchgit {
    url = "https://git.launchpad.net/lazr.config";
    rev = "3c659114e8e947fbd46954336f5577351d786de9";
    hash = "sha256-eYJY4JRoqTMG4j1jyiYrI8xEKdJ+wQYVVU/6OqVIodk=";
  };

  nativeCheckInputs = [ pytestCheckHook ];

  # change the directory to avoid a namespace-related problem
  # ModuleNotFoundError: No module named 'lazr.delegates'
  preCheck = ''
    cd $out
  '';

  build-system = [ setuptools ];

  dependencies = [
    lazr-delegates
    zope-interface
  ];

  pyproject = true;
  pythonImportsCheck = [ "lazr.config" ];
  pythonNamespaces = [ "lazr" ];

  meta = {
    description = "Create configuration schemas, and process and validate configurations";
    homepage = "https://launchpad.net/lazr.config";
    changelog = "https://git.launchpad.net/lazr.config/tree/NEWS.rst?h=${version}";
    license = lib.licenses.lgpl3Only;
  };
}

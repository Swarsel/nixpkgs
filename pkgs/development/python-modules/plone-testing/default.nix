{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  setuptools,
  zope-testing,
}:

buildPythonPackage rec {
  pname = "plone-testing";
  version = "9.0.7";

  src = fetchFromGitHub {
    owner = "plone";
    repo = "plone.testing";
    tag = version;
    hash = "sha256-5DaN0o/EaWwdMvmLW12zdNXJ3p6dowALJ10zrhUT3dA=";
  };

  # Huge amount of testing dependencies (including Zope2)
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    setuptools
    zope-testing
  ];

  pyproject = true;
  pythonImportsCheck = [ "plone.testing" ];
  pythonNamespaces = [ "plone" ];

  meta = {
    description = "Testing infrastructure for Zope and Plone projects";
    homepage = "https://github.com/plone/plone.testing";
    changelog = "https://github.com/plone/plone.testing/blob/${src.tag}/CHANGES.rst";
    license = lib.licenses.bsd3;
  };
}

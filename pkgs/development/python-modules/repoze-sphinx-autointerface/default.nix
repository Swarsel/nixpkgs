{
  lib,
  buildPythonPackage,
  fetchPypi,
  pytestCheckHook,
  setuptools,
  sphinx,
  zope-interface,
  zope-testrunner,
}:

buildPythonPackage rec {
  pname = "repoze-sphinx-autointerface";
  version = "1.0.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-SGvxQjpGlrkVPkiM750ybElv/Bbd6xSwyYh7RsYOKKE=";
    pname = "repoze.sphinx.autointerface";
  };

  nativeBuildInputs = [ setuptools ];

  propagatedBuildInputs = [
    zope-interface
    sphinx
  ];

  nativeCheckInputs = [
    pytestCheckHook
    zope-testrunner
  ];

  pyproject = true;
  pythonImportsCheck = [ "repoze.sphinx.autointerface" ];

  pythonNamespaces = [
    "repoze"
    "repoze.sphinx"
  ];

  meta = {
    description = "Auto-generate Sphinx API docs from Zope interfaces";
    homepage = "https://github.com/repoze/repoze.sphinx.autointerface";
    changelog = "https://github.com/repoze/repoze.sphinx.autointerface/blob/${version}/CHANGES.rst";
    license = lib.licenses.bsd0;
    maintainers = [ ];
    # https://github.com/repoze/repoze.sphinx.autointerface/issues/21
    broken = lib.versionAtLeast sphinx.version "7.2";
  };
}

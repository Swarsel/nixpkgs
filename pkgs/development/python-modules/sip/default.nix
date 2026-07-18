{
  lib,
  buildPythonPackage,
  fetchPypi,
  packaging,
  # tests
  poppler-qt5,
  qgis,
  qgis-ltr,
  setuptools,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "sip";
  version = "6.15.1";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-3C5YwXmKdOGzHCjoNzOYIv6PpVKIrjDomG6ygQDrylo=";
  };

  # There aren't tests
  doCheck = false;

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    packaging
    setuptools
  ];

  pyproject = true;
  pythonImportsCheck = [ "sipbuild" ];

  passthru.tests = {
    # test depending packages
    inherit poppler-qt5 qgis qgis-ltr;
  };

  meta = {
    description = "Creates C++ bindings for Python modules";
    homepage = "https://riverbankcomputing.com/";
    license = lib.licenses.gpl3Only;
    maintainers = [ ];
  };
}

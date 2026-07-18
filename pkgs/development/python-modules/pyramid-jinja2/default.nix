{
  lib,
  buildPythonPackage,
  fetchPypi,
  jinja2,
  markupsafe,
  pyramid,
  pytest-cov-stub,
  pytestCheckHook,
  webtest,
  zope-deprecation,
}:

buildPythonPackage rec {
  pname = "pyramid-jinja2";
  version = "2.10.1";

  src = fetchPypi {
    inherit version;
    hash = "sha256-jFCMs1wTX5UUnKI2EQ+ciHU0NXV0DRbFy3OlDvHCFnc=";
    pname = "pyramid_jinja2";
  };

  propagatedBuildInputs = [
    markupsafe
    jinja2
    pyramid
    zope-deprecation
  ];

  nativeCheckInputs = [
    webtest
    pytestCheckHook
    pytest-cov-stub
  ];

  disabledTests = [
    # AssertionError: Lists differ: ['pyramid_jinja2-2.10',...
    "test_it_relative_to_package"
    # AssertionError: False is not true
    "test_options"
  ];

  format = "setuptools";
  pythonImportsCheck = [ "pyramid_jinja2" ];

  meta = {
    description = "Jinja2 template bindings for the Pyramid web framework";
    homepage = "https://github.com/Pylons/pyramid_jinja2";
    license = lib.licenses.bsd0;
    maintainers = [ ];
  };
}

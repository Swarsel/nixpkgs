{
  lib,
  buildPythonPackage,
  fetchPypi,
  genshi,
  gunicorn,
  jinja2,
  mako,
  pytestCheckHook,
  setuptools,
  sqlalchemy,
  virtualenv,
  webob,
  webtest,
}:

buildPythonPackage (finalAttrs: {
  pname = "pecan";
  version = "1.8.0";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-L5+86obo2/Gi0olUIlVHY0oonbcgHndkUWpdzobBFt4=";
  };

  nativeCheckInputs = [
    genshi
    gunicorn
    jinja2
    pytestCheckHook
    sqlalchemy
    virtualenv
    webtest
  ];

  build-system = [ setuptools ];

  dependencies = [
    mako
    setuptools
    webob
  ];

  pyproject = true;

  pytestFlags = [
    "--pyargs"
    "pecan"
  ];

  pythonImportsCheck = [ "pecan" ];

  meta = {
    description = "WSGI object-dispatching web framework";
    homepage = "https://www.pecanpy.org/";
    changelog = "https://github.com/pecan/pecan/releases/tag/${finalAttrs.version}";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ applePrincess ];
  };
})

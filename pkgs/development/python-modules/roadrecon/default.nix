{
  lib,
  aiohttp,
  buildPythonPackage,
  fetchPypi,
  flask,
  flask-cors,
  flask-marshmallow,
  flask-sqlalchemy,
  marshmallow,
  marshmallow-sqlalchemy,
  openpyxl,
  roadlib,
  setuptools,
  sqlalchemy,
}:

buildPythonPackage (finalAttrs: {
  pname = "roadrecon";
  version = "2.0.0";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-wzr0J6tGhsZdjTDeIeSzCRTquiw4iZ8FxqFEl1fC2iU=";
  };

  # Module has no tests
  doCheck = false;
  __structuredAttrs = true;
  build-system = [ setuptools ];

  dependencies = [
    aiohttp
    flask
    flask-cors
    flask-marshmallow
    flask-sqlalchemy
    marshmallow
    marshmallow-sqlalchemy
    openpyxl
    roadlib
    sqlalchemy
  ];

  pyproject = true;
  pythonImportsCheck = [ "roadtools.roadrecon" ];

  pythonRelaxDeps = [
    "marshmallow"
    "flask"
  ];

  meta = {
    description = "Azure AD recon";
    homepage = "https://pypi.org/project/roadrecon/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
})

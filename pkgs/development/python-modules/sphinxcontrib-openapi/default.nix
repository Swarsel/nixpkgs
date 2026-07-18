{
  lib,
  buildPythonPackage,
  deepmerge,
  fetchPypi,
  jsonschema,
  picobox,
  pyyaml,
  setuptools-scm,
  sphinx-mdinclude,
  sphinxcontrib-httpdomain,
}:

buildPythonPackage rec {
  pname = "sphinxcontrib-openapi";
  version = "0.8.4";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-34g4CKW15LQROtaXGFxDo/Qt89znBFOveLpwdpB+miA=";
  };

  nativeBuildInputs = [ setuptools-scm ];

  propagatedBuildInputs = [
    deepmerge
    jsonschema
    picobox
    pyyaml
    sphinx-mdinclude
    sphinxcontrib-httpdomain
  ];

  doCheck = false;
  format = "setuptools";
  pythonNamespaces = [ "sphinxcontrib" ];

  meta = {
    description = "OpenAPI (fka Swagger) spec renderer for Sphinx";
    homepage = "https://github.com/ikalnytskyi/sphinxcontrib-openapi";
    license = lib.licenses.bsd0;
    maintainers = [ lib.maintainers.flokli ];
  };
}

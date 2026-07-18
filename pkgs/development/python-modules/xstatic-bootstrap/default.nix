{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "xstatic-bootstrap";
  version = "5.3.8.0";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-BPXMlbvlQ40ehR0GxMoa1/hL02oJtN5aH1S1JOhQaFk=";
    pname = "xstatic_bootstrap";
  };

  # no tests implemented
  doCheck = false;
  __structuredAttrs = true;
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "xstatic.pkg.bootstrap" ];

  meta = {
    description = "Bootstrap packaged static files for python";
    homepage = "https://getbootstrap.com";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ makefu ];
  };
})

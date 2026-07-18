{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "xstatic-pygments";
  version = "2.9.0.1";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-CCwen+YG+770dPeLb9sZ6aLvzHqbfZQWPPZve/rnV2I=";
    pname = "XStatic-Pygments";
  };

  # no tests implemented
  doCheck = false;
  __structuredAttrs = true;
  build-system = [ setuptools ];
  pyproject = true;

  meta = {
    description = "Pygments packaged static files for python";
    homepage = "https://pygments.org";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ makefu ];
  };
})

{
  lib,
  beautifulsoup4,
  buildPythonPackage,
  docutils,
  fetchPypi,
  gitpython,
  requests,
  setuptools,
  sphinx,
}:

buildPythonPackage rec {
  pname = "canonical-sphinx-extensions";
  version = "0.0.34";

  src = fetchPypi {
    inherit version;
    hash = "sha256-y9wiXj4FOkOt3Pt2EFbX5xO+f8V5eaI0G6LzuGbdY0o=";
    pname = "canonical_sphinx_extensions";
  };

  doCheck = false;

  build-system = [
    setuptools
  ];

  dependencies = [
    beautifulsoup4
    docutils
    gitpython
    requests
    sphinx
  ];

  pyproject = true;

  meta = {
    description = "Collection of Sphinx extensions used by Canonical documentation";
    homepage = "https://pypi.org/project/canonical-sphinx-extensions";
    license = lib.licenses.asl20;
    maintainers = [ ];
  };
}

{
  lib,
  buildPythonPackage,
  fetchPypi,
  pymongo,
  setuptools,
  spotapi,
}:

buildPythonPackage (finalAttrs: {
  pname = "spotipyfree";
  version = "1.9.13";

  # no tags on GitHub
  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-jbeZNoB1Sep73ccJaggFZb2AGq5OSZf6f/OzWwFB+pA=";
  };

  # upstream has no tests
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    pymongo
    spotapi
  ];

  pyproject = true;
  pythonImportsCheck = [ "SpotipyFree" ];

  meta = {
    description = "Spotipy-compatible wrapper using SpotAPI";
    homepage = "https://github.com/TzurSoffer/spotipyFree";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.dotlambda ];
  };
})

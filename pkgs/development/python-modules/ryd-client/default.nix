{
  lib,
  buildPythonPackage,
  fetchPypi,
  requests,
  setuptools,
}:
buildPythonPackage rec {
  pname = "ryd-client";
  version = "0.0.6";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-PxrVdVw+dAkF8WWzYyg2/B5CFurNPA5XRNtH9uu/SiY=";
  };

  # no tests
  doCheck = false;
  build-system = [ setuptools ];
  dependencies = [ requests ];
  pyproject = true;
  pythonImportsCheck = [ "ryd_client" ];

  meta = {
    description = "Python client library for the Return YouTube Dislike API";
    homepage = "https://github.com/bbilly1/ryd-client";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.ericthemagician ];
  };
}

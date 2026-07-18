{
  lib,
  buildPythonPackage,
  fetchPypi,
  flask,
  setuptools,
  six,
}:

buildPythonPackage (finalAttrs: {
  pname = "github-webhook";
  version = "1.0.4";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    sha256 = "b2444dbfd03deda35792bd00ebd1692597c2605c61445da79da6322afaca7a8d";
  };

  # touches network
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    flask
    six
  ];

  pyproject = true;

  meta = {
    description = "Framework for writing webhooks for GitHub";
    homepage = "https://github.com/bloomberg/python-github-webhook";
    license = lib.licenses.mit;
  };
})

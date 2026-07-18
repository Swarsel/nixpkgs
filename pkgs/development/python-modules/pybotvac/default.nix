{
  lib,
  buildPythonPackage,
  fetchPypi,
  requests,
  requests-oauthlib,
  setuptools,
  voluptuous,
}:

buildPythonPackage (finalAttrs: {
  pname = "pybotvac";
  version = "0.0.29";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-9mapPFzdAAzHJFuFaxiyGh0utznzTSXzRa6AZRj/Oq8=";
  };

  # Module no tests
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    requests
    requests-oauthlib
    voluptuous
  ];

  pyproject = true;
  pythonImportsCheck = [ "pybotvac" ];

  meta = {
    description = "Python module for interacting with Neato Botvac Connected vacuum robots";
    homepage = "https://github.com/stianaske/pybotvac";
    changelog = "https://github.com/stianaske/pybotvac/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
})

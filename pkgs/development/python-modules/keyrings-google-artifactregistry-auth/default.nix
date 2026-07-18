{
  lib,
  buildPythonPackage,
  fetchPypi,
  google-auth,
  keyring,
  pluggy,
  requests,
  setuptools,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "keyrings-google-artifactregistry-auth";
  version = "1.1.2";

  src = fetchPypi {
    inherit version;
    hash = "sha256-vWq7cnQNLf60pcA8OxBcb326FpyqKd7jlZaU8fAsd94=";
    pname = "keyrings.google-artifactregistry-auth";
  };

  # upstream has no tests
  doCheck = false;

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    google-auth
    keyring
    pluggy
    requests
  ];

  pyproject = true;
  pythonImportsCheck = [ "keyrings.gauth" ];

  meta = {
    description = "Python package which allows you to configure keyring to interact with Python repositories stored in Artifact Registry";
    homepage = "https://github.com/GoogleCloudPlatform/artifact-registry-python-tools";
    changelog = "https://github.com/GoogleCloudPlatform/artifact-registry-python-tools/blob/main/HISTORY.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ lovesegfault ];
  };
}

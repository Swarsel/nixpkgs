{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cryptography,
  jeepney,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "secretstorage";
  version = "3.5.0";

  src = fetchFromGitHub {
    owner = "mitya57";
    repo = "secretstorage";
    tag = finalAttrs.version;
    hash = "sha256-oDna9i6ny/mKHpOzrtfaYPnd12qsZ84TTxl4g+RWE24=";
  };

  # Needs a D-Bus session
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    cryptography
    jeepney
  ];

  pyproject = true;
  pythonImportsCheck = [ "secretstorage" ];

  meta = {
    description = "Python bindings to FreeDesktop.org Secret Service API";
    homepage = "https://github.com/mitya57/secretstorage";
    changelog = "https://github.com/mitya57/secretstorage/blob/${finalAttrs.src.tag}/changelog";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ teto ];
  };
})

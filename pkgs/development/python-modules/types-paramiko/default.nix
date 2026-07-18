{
  lib,
  buildPythonPackage,
  cryptography,
  fetchPypi,
  setuptools,
}:
buildPythonPackage (finalAttrs: {
  pname = "types-paramiko";
  version = "5.0.0.20260617";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-UKWw3GiznTAJfLfZO0kV27yX7XQOpjO9SSviXKHyXfQ=";
    pname = "types_paramiko";
  };

  # Modules doesn't have tests
  doCheck = false;
  __structuredAttrs = true;
  build-system = [ setuptools ];

  dependencies = [
    cryptography
  ];

  pyproject = true;
  pythonImportsCheck = [ "paramiko-stubs" ];

  meta = {
    description = "Typing stubs for paramiko";
    homepage = "https://github.com/python/typeshed";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ daspk04 ];
  };
})

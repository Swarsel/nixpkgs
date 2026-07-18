{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
}:

buildPythonPackage rec {
  pname = "validate-email";
  version = "1.3";

  src = fetchPypi {
    inherit version;
    hash = "sha256-eEcZ3F94C+MZzdGF3IXdk6/r2267lDgRvEx8X5xyrq8=";
    pname = "validate_email";
  };

  # No tests
  doCheck = false;
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "validate_email" ];

  meta = {
    description = "Verify if an email address is valid and really exists";
    homepage = "https://github.com/syrusakbary/validate_email";
    license = lib.licenses.lgpl3Plus;
    maintainers = with lib.maintainers; [ mmahut ];
  };
}

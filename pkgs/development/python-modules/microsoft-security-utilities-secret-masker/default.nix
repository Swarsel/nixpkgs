{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
  wheel,
}:

buildPythonPackage rec {
  pname = "microsoft-security-utilities-secret-masker";
  version = "1.0.0b4";

  src = fetchPypi {
    inherit version;
    hash = "sha256-owvTYawYyLUvaEQHa8JkZTNZSeqcegBNlfUZbsb97z4=";
    pname = "microsoft_security_utilities_secret_masker";
  };

  build-system = [
    setuptools
    wheel
  ];

  pyproject = true;

  pythonImportsCheck = [
    "microsoft_security_utilities_secret_masker"
  ];

  meta = {
    description = "Tool for detecting and masking secrets";
    homepage = "https://pypi.org/project/microsoft-security-utilities-secret-masker/";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}

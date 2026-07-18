{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
}:

buildPythonPackage rec {
  pname = "safe-pysha3";
  version = "1.0.5";

  src = fetchPypi {
    inherit version;
    hash = "sha256-iM6q1q9La97NL1SzGtDl5eIQ1PXsq7G9H9NTmtYbe/E=";
    pname = "safe_pysha3";
  };

  build-system = [
    setuptools
  ];

  pyproject = true;
  pythonImportsCheck = [ "sha3" ];

  meta = {
    description = "SHA-3 (Keccak) for Python 3.9 - 3.13";
    homepage = "https://github.com/5afe/pysha3";
    changelog = "https://github.com/5afe/pysha3/releases/tag/v${version}";
    license = lib.licenses.psfl;
    maintainers = with lib.maintainers; [ wegank ];
  };
}

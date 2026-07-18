{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  setuptools,
}:

buildPythonPackage rec {
  pname = "crcelk";
  version = "1.3";

  src = fetchFromGitHub {
    owner = "zeroSteiner";
    repo = "crcelk";
    tag = "v${version}";
    hash = "sha256-eJt0qcG0ejTQJyjOSi6Au2jH801KOMnk7f6cLbd7ADw=";
  };

  # Module has no tests
  doCheck = false;
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "crcelk" ];

  meta = {
    description = "Implementation of the CRC algorithm";
    homepage = "https://github.com/zeroSteiner/crcelk";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
}

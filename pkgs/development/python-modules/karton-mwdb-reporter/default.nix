{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  karton-core,
  mwdblib,
}:

buildPythonPackage rec {
  pname = "karton-mwdb-reporter";
  version = "1.3.0";

  src = fetchFromGitHub {
    owner = "CERT-Polska";
    repo = "karton-mwdb-reporter";
    tag = "v${version}";
    hash = "sha256-KJh9uJzVGYEEk1ed56ynKA/+dK9ouDB7L06xERjfjdc=";
  };

  propagatedBuildInputs = [
    karton-core
    mwdblib
  ];

  # Project has no tests
  doCheck = false;
  format = "setuptools";
  pythonImportsCheck = [ "karton.mwdb_reporter" ];

  meta = {
    description = "Karton service that uploads analyzed artifacts and metadata to MWDB Core";
    homepage = "https://github.com/CERT-Polska/karton-mwdb-reporter";
    changelog = "https://github.com/CERT-Polska/karton-mwdb-reporter/releases/tag/v${version}";
    license = with lib.licenses; [ bsd3 ];
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "karton-mwdb-reporter";
  };
}

{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  karton-core,
  malduck,
}:

buildPythonPackage rec {
  pname = "karton-config-extractor";
  version = "2.3.1";

  src = fetchFromGitHub {
    owner = "CERT-Polska";
    repo = "karton-config-extractor";
    tag = "v${version}";
    hash = "sha256-a9wSw25q0blgAkR2s3brW7jGHJSLjx1yXjMmhMJNUFk=";
  };

  propagatedBuildInputs = [
    karton-core
    malduck
  ];

  # Project has no tests
  doCheck = false;
  format = "setuptools";
  pythonImportsCheck = [ "karton.config_extractor" ];
  pythonRelaxDeps = [ "malduck" ];

  meta = {
    description = "Static configuration extractor for the Karton framework";
    homepage = "https://github.com/CERT-Polska/karton-config-extractor";
    changelog = "https://github.com/CERT-Polska/karton-config-extractor/releases/tag/${src.tag}";
    license = with lib.licenses; [ bsd3 ];
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "karton-config-extractor";
  };
}

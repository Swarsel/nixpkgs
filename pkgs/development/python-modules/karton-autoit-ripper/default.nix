{
  lib,
  fetchFromGitHub,
  autoit-ripper,
  buildPythonPackage,
  karton-core,
  malduck,
  regex,
  setuptools,
}:

buildPythonPackage rec {
  pname = "karton-autoit-ripper";
  version = "1.2.0";

  src = fetchFromGitHub {
    owner = "CERT-Polska";
    repo = "karton-autoit-ripper";
    tag = "v${version}";
    hash = "sha256-D+M3JsIN8LUWg8GVweEzySHI7KaBb6cNHHn4pXoq55M=";
  };

  # Module has no tests
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    autoit-ripper
    karton-core
    malduck
    regex
  ];

  pyproject = true;
  pythonImportsCheck = [ "karton.autoit_ripper" ];

  pythonRelaxDeps = [
    "autoit-ripper"
    "malduck"
    "regex"
  ];

  meta = {
    description = "AutoIt script ripper for Karton framework";
    homepage = "https://github.com/CERT-Polska/karton-autoit-ripper";
    changelog = "https://github.com/CERT-Polska/karton-autoit-ripper/releases/tag/v${version}";
    license = with lib.licenses; [ bsd3 ];
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "karton-autoit-ripper";
  };
}

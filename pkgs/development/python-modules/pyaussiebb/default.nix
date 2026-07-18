{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  pdm-backend,
  pydantic,
  requests,
}:

buildPythonPackage rec {
  pname = "pyaussiebb";
  version = "0.1.6";

  src = fetchFromGitHub {
    owner = "yaleman";
    repo = "aussiebb";
    tag = "v${version}";
    hash = "sha256-GD04Bq+uJs2JuTjtnGh6QKD4uFXwmGcOMB1Hu9yBlkI=";
  };

  # Tests require credentials and requests-testing
  doCheck = false;
  build-system = [ pdm-backend ];

  dependencies = [
    aiohttp
    requests
    pydantic
  ];

  pyproject = true;
  pythonImportsCheck = [ "aussiebb" ];

  meta = {
    description = "Module for interacting with the Aussie Broadband APIs";
    homepage = "https://github.com/yaleman/aussiebb";
    changelog = "https://github.com/yaleman/pyaussiebb/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
}

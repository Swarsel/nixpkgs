{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  requests,
  setuptools,
}:

buildPythonPackage rec {
  pname = "python-etherscan-api";
  version = "2.1.0";

  src = fetchFromGitHub {
    owner = "pcko1";
    repo = "etherscan-python";
    tag = version;
    hash = "sha256-HnMhWUKwVQq5RMXwSZo9q20JEnl7YN13ju01L18YAzU=";
  };

  # Tests require an API key
  doCheck = false;
  build-system = [ setuptools ];
  dependencies = [ requests ];
  pyproject = true;
  pythonImportsCheck = [ "etherscan" ];

  meta = {
    description = "A minimal, yet complete, python API for etherscan.io";
    homepage = "https://github.com/pcko1/etherscan-python";
    changelog = "https://github.com/pcko1/etherscan-python/releases/tag/${version}";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.jamiemagee ];
  };
}

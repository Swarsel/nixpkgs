{
  lib,
  fetchFromGitHub,
  aiohttp,
  async-timeout,
  buildPythonPackage,
}:

buildPythonPackage rec {
  pname = "pyevilgenius";
  version = "2.0.0";

  src = fetchFromGitHub {
    owner = "home-assistant-libs";
    repo = "pyevilgenius";
    rev = version;
    hash = "sha256-wjC32oq/lW3Z4XB+4SILRKIOuCgBKk1gruOo4uc/4/o=";
  };

  propagatedBuildInputs = [
    aiohttp
    async-timeout
  ];

  # Project has no test
  doCheck = false;
  format = "setuptools";
  pythonImportsCheck = [ "pyevilgenius" ];

  meta = {
    description = "Python SDK to interact with Evil Genius Labs devices";
    homepage = "https://github.com/home-assistant-libs/pyevilgenius";
    changelog = "https://github.com/home-assistant-libs/pyevilgenius/releases/tag/${version}";
    license = with lib.licenses; [ asl20 ];
    maintainers = with lib.maintainers; [ fab ];
  };
}

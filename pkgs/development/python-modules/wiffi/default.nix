{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "wiffi";
  version = "1.1.2";

  src = fetchFromGitHub {
    owner = "mampfes";
    repo = "python-wiffi";
    tag = finalAttrs.version;
    hash = "sha256-pnbzJxq8K947Yg54LysPPho6IRKf0cc+szTETgyzFao=";
  };

  # Project has no tests
  doCheck = false;
  __structuredAttrs = true;
  build-system = [ setuptools ];
  dependencies = [ aiohttp ];
  pyproject = true;
  pythonImportsCheck = [ "wiffi" ];

  meta = {
    description = "Python module to interface with STALL WIFFI devices";
    homepage = "https://github.com/mampfes/python-wiffi";
    changelog = "https://github.com/mampfes/python-wiffi/blob/${finalAttrs.version}/HISTORY.md";
    license = with lib.licenses; [ mit ];
    maintainers = with lib.maintainers; [ fab ];
  };
})

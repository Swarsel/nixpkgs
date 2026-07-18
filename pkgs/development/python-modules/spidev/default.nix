{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  setuptools,
}:

buildPythonPackage rec {
  pname = "spidev";
  version = "3.8";

  src = fetchFromGitHub {
    owner = "doceme";
    repo = "py-spidev";
    tag = "v${version}";
    hash = "sha256-ysOLZWsMiHjPxQ7fMWsywp44vkNGFGH8n6X7zk7XQck=";
  };

  doCheck = false; # no tests
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "spidev" ];

  meta = {
    description = "Python bindings for Linux SPI access through spidev";
    homepage = "https://github.com/doceme/py-spidev";
    changelog = "https://github.com/doceme/py-spidev/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ hexa ];
    platforms = lib.platforms.linux;
  };
}

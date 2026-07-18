{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  poetry-core,
  pycryptodome,
  xmltodict,
}:

buildPythonPackage rec {
  pname = "panasonic-viera";
  version = "0.4.4";

  src = fetchFromGitHub {
    owner = "florianholzapfel";
    repo = "panasonic-viera";
    tag = version;
    hash = "sha256-f/FLM6xoJwRZwq8Q6uf9W+fJN96wE6HvJozaNVmORtg=";
  };

  # upstream has no tests
  doCheck = false;
  build-system = [ poetry-core ];

  dependencies = [
    aiohttp
    pycryptodome
    xmltodict
  ];

  pyproject = true;
  pythonImportsCheck = [ "panasonic_viera" ];

  meta = {
    description = "Library to control Panasonic Viera TVs";
    homepage = "https://github.com/florianholzapfel/panasonic-viera";
    changelog = "https://github.com/florianholzapfel/panasonic-viera/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}

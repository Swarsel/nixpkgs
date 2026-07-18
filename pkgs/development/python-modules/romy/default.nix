{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  setuptools,
}:

buildPythonPackage rec {
  pname = "romy";
  version = "0.0.10";

  src = fetchFromGitHub {
    owner = "xeniter";
    repo = "romy";
    tag = version;
    hash = "sha256-pQI+/1xt1YE+L5CHsurkBr2dKMGR/dV5vrGHYM8wNGs=";
  };

  # Module has no tests
  doCheck = false;
  build-system = [ setuptools ];
  dependencies = [ aiohttp ];
  pyproject = true;
  pythonImportsCheck = [ "romy" ];

  meta = {
    description = "Library to control Wi-Fi enabled ROMY vacuum cleaners";
    homepage = "https://github.com/xeniter/romy";
    changelog = "https://github.com/xeniter/romy/releases/tag/${version}";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ fab ];
  };
}

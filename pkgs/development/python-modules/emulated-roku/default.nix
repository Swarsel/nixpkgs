{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  setuptools,
}:

buildPythonPackage rec {
  pname = "emulated-roku";
  version = "0.5.1";

  src = fetchFromGitHub {
    owner = "mindigmarton";
    repo = "emulated_roku";
    tag = version;
    hash = "sha256-KwDEajkrEEgobORetM/rROMDLZvw9AJmmr1jmXAJJbk=";
  };

  # no tests implemented
  doCheck = false;
  build-system = [ setuptools ];
  dependencies = [ aiohttp ];
  pyproject = true;
  pythonImportsCheck = [ "emulated_roku" ];

  meta = {
    description = "Library to emulate a roku server to serve as a proxy for remotes such as Harmony";
    homepage = "https://github.com/mindigmarton/emulated_roku";
    changelog = "https://github.com/martonperei/emulated_roku/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}

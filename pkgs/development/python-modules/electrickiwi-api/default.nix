{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  poetry-core,
}:

buildPythonPackage rec {
  pname = "electrickiwi-api";
  version = "0.9.14";

  src = fetchFromGitHub {
    owner = "mikey0000";
    repo = "EK-API";
    tag = "v${version}";
    hash = "sha256-UXweOz5olwx3ZI2M7eI1n729tqfLiWszV2zTWbrA9CM=";
  };

  # Tests require authentication credentials
  doCheck = false;
  build-system = [ poetry-core ];
  dependencies = [ aiohttp ];
  pyproject = true;
  pythonImportsCheck = [ "electrickiwi_api" ];

  meta = {
    description = "Python library for interfacing with the Electric Kiwi power company API";
    homepage = "https://github.com/mikey0000/EK-API";
    license = lib.licenses.gpl3Only;
    maintainers = [ lib.maintainers.jamiemagee ];
  };
}

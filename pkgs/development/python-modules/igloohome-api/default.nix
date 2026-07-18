{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  dacite,
  hatchling,
  pyjwt,
}:

buildPythonPackage (finalAttrs: {
  pname = "igloohome-api";
  version = "0.1.1";

  src = fetchFromGitHub {
    owner = "keithle888";
    repo = "igloohome-api";
    tag = "v${finalAttrs.version}";
    hash = "sha256-BLmmypbvYTgQisT0+9Ym1ZTK6asAP2tWXP2DWhKYM7U=";
  };

  # upstream has no tests
  doCheck = false;
  build-system = [ hatchling ];

  dependencies = [
    aiohttp
    dacite
    pyjwt
  ];

  pyproject = true;
  pythonImportsCheck = [ "igloohome_api" ];

  meta = {
    description = "Python package for using igloohome's API";
    homepage = "https://github.com/keithle888/igloohome-api";
    changelog = "https://github.com/keithle888/igloohome-api/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
})

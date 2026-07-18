{
  lib,
  aiohttp,
  buildPythonPackage,
  fetchPypi,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "advantage-air";
  version = "0.4.4";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-4rRR9IxzH5EiYfWzWYeyCwoLB2LetBVyH7L3nkvp+gA=";
    pname = "advantage_air";
  };

  # No tests
  doCheck = false;
  build-system = [ setuptools ];
  dependencies = [ aiohttp ];
  pyproject = true;
  pythonImportsCheck = [ "advantage_air" ];

  meta = {
    description = "API helper for Advantage Air's MyAir and e-zone API";
    homepage = "https://github.com/Bre77/advantage_air";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ jamiemagee ];
  };
})

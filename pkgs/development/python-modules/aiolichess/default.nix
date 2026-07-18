{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  hatchling,
}:

buildPythonPackage (finalAttrs: {
  pname = "aiolichess";
  version = "1.3.0";

  src = fetchFromGitHub {
    owner = "aryanhasgithub";
    repo = "aiolichess";
    tag = "v${finalAttrs.version}";
    hash = "sha256-cJuaEjapvmmRypJHvkveBxjAvGpkq0tjguXJLktnb74=";
  };

  # upstream tests are empty
  doCheck = false;
  build-system = [ hatchling ];
  dependencies = [ aiohttp ];
  pyproject = true;
  pythonImportsCheck = [ "aiolichess" ];

  meta = {
    description = "Async Python client for the Lichess REST API";
    homepage = "https://github.com/aryanhasgithub/aiolichess";
    changelog = "https://github.com/aryanhasgithub/aiolichess/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.gpl3Only;
    maintainers = [ lib.maintainers.jamiemagee ];
  };
})

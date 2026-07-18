{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  hatch-vcs,
  hatchling,
}:

buildPythonPackage (finalAttrs: {
  pname = "aiodocker";
  version = "0.27.0";

  src = fetchFromGitHub {
    owner = "aio-libs";
    repo = "aiodocker";
    tag = "v${finalAttrs.version}";
    hash = "sha256-l7CATx+kqT9aG3c523ctK0ooJDaJHw1Hf8Ow7EqFkDs=";
  };

  # tests require docker daemon
  doCheck = false;

  build-system = [
    hatchling
    hatch-vcs
  ];

  dependencies = [
    aiohttp
  ];

  pyproject = true;
  pythonImportsCheck = [ "aiodocker" ];

  meta = {
    description = "Docker API client for asyncio";
    homepage = "https://github.com/aio-libs/aiodocker";
    changelog = "https://github.com/aio-libs/aiodocker/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ emilytrau ];
  };
})

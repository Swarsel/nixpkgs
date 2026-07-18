{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  cryptography,
  hatchling,
  msgpack,
}:

buildPythonPackage (finalAttrs: {
  pname = "wslink";
  version = "2.5.7";

  src = fetchFromGitHub {
    owner = "kitware";
    repo = "wslink";
    tag = "v${finalAttrs.version}";
    hash = "sha256-47vHc+b5Z3ipkLZ5k0yEasNaKz0Seu2jiGBVmAI5u6U=";
  };

  # doCheck need interacting with the http server
  doCheck = false;
  build-system = [ hatchling ];

  dependencies = [
    aiohttp
    msgpack
  ];

  optional-dependencies = {
    ssl = [ cryptography ];
  };

  pyproject = true;
  pythonImportsCheck = [ "wslink" ];

  meta = {
    description = "Python/JavaScript library for communicating over WebSocket";
    homepage = "https://github.com/Kitware/wslink";
    changelog = "https://github.com/Kitware/wslink/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ qbisi ];
  };
})

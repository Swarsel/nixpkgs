{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # dependencies
  fastapi,
  # build-system
  hatchling,
  pydantic,
  typing-extensions,
}:

buildPythonPackage (finalAttrs: {
  pname = "fastapi-pagination";
  version = "0.15.15";

  src = fetchFromGitHub {
    owner = "uriyyo";
    repo = "fastapi-pagination";
    tag = finalAttrs.version;
    hash = "sha256-G6qF57MWlrZ4Poc+M2YtpKqquhOR/Zh4TnFmL2qZ1Uk=";
  };

  # Tests require network access
  doCheck = false;
  __structuredAttrs = true;

  build-system = [
    hatchling
  ];

  dependencies = [
    fastapi
    pydantic
    typing-extensions
  ];

  pyproject = true;
  pythonImportsCheck = [ "fastapi_pagination" ];

  meta = {
    description = "FastAPI pagination";
    homepage = "https://github.com/uriyyo/fastapi-pagination";
    changelog = "https://github.com/uriyyo/fastapi-pagination/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ GaetanLepage ];
  };
})

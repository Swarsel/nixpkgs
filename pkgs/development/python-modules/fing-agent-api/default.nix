{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  httpx,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "fing-agent-api";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "fingltd";
    repo = "fing-agent-pyapi";
    tag = finalAttrs.version;
    hash = "sha256-RUV6/iSA82/aQoWfsp/3iPnqwJ4xjMbO/NR/ut4qORU=";
  };

  # upstream has no tests
  doCheck = false;
  build-system = [ setuptools ];
  dependencies = [ httpx ];
  pyproject = true;
  pythonImportsCheck = [ "fing_agent_api" ];

  meta = {
    description = "Python library for interacting with the Fingbox local APIs";
    homepage = "https://github.com/fingltd/fing-agent-pyapi";
    changelog = "https://github.com/fingltd/fing-agent-pyapi/releases/tag/${finalAttrs.version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ jamiemagee ];
  };
})

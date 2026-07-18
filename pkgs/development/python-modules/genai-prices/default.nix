{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # dependencies
  httpx2,
  pydantic,
  # build-system
  uv-build,
}:

buildPythonPackage (finalAttrs: {
  pname = "genai-prices";
  version = "0.0.71";

  src = fetchFromGitHub {
    owner = "pydantic";
    repo = "genai-prices";
    tag = "v${finalAttrs.version}";
    hash = "sha256-IFBdpXJ0AE3UNNqUlOrYMIgRGeB87BYbNqb4GvtJkl0=";
  };

  doCheck = false; # no tests

  build-system = [
    uv-build
  ];

  dependencies = [
    httpx2
    pydantic
  ];

  pyproject = true;

  pythonImportsCheck = [
    "genai_prices"
  ];

  sourceRoot = "${finalAttrs.src.name}/packages/python";

  meta = {
    description = "Calculate prices for calling LLM inference APIs";
    homepage = "https://github.com/pydantic/genai-prices";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ hexa ];
  };
})

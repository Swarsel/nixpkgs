{
  lib,
  fetchFromGitHub,
  backoff,
  buildPythonPackage,
  httpx,
  opentelemetry-api,
  opentelemetry-exporter-otlp,
  opentelemetry-sdk,
  packaging,
  poetry-core,
  pydantic,
  wrapt,
}:

buildPythonPackage (finalAttrs: {
  pname = "langfuse";
  version = "4.0.2";

  src = fetchFromGitHub {
    owner = "langfuse";
    repo = "langfuse-python";
    tag = "v${finalAttrs.version}";
    hash = "sha256-BTwCAyqZMic5sOVAXOhhS6H1SBoEePo1fGOt5vLiLUo=";
  };

  # tests require network access and openai api key
  doCheck = false;
  build-system = [ poetry-core ];

  dependencies = [
    backoff
    httpx
    opentelemetry-api
    opentelemetry-sdk
    opentelemetry-exporter-otlp
    packaging
    pydantic
    wrapt
  ];

  pyproject = true;
  pythonImportsCheck = [ "langfuse" ];

  meta = {
    description = "Instrument your LLM app with decorators or low-level SDK and get detailed tracing/observability";
    homepage = "https://github.com/langfuse/langfuse-python";
    changelog = "https://github.com/langfuse/langfuse-python/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ natsukium ];
  };
})

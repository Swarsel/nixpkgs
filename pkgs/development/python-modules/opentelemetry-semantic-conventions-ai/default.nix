{
  lib,
  buildPythonPackage,
  fetchPypi,
  hatchling,
  opentelemetry-sdk,
  opentelemetry-semantic-conventions,
  pytestCheckHook,
}:
let
  version = "0.5.1";
in
buildPythonPackage {
  inherit version;
  pname = "opentelemetry-semantic-conventions-ai";

  src = fetchPypi {
    inherit version;
    hash = "sha256-FTkGIA2MHS+OCb142+9SaRYCPehaw9qzWRK/r7af8Ew=";
    pname = "opentelemetry_semantic_conventions_ai";
  };

  nativeCheckInputs = [
    pytestCheckHook
  ];

  build-system = [ hatchling ];

  dependencies = [
    opentelemetry-sdk
    opentelemetry-semantic-conventions
  ];

  pyproject = true;
  pythonImportsCheck = [ "opentelemetry.semconv_ai" ];

  meta = {
    description = "Open-source observability for your GenAI or LLM application, based on OpenTelemetry";
    homepage = "https://github.com/traceloop/openllmetry/tree/main/packages/opentelemetry-semantic-conventions-ai";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ lach ];
  };
}

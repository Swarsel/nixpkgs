{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hatchling,
  nix-update-script,
  pytest-asyncio,
  pytestCheckHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "openinference-semantic-conventions";
  version = "0.1.30";

  src = fetchFromGitHub {
    owner = "Arize-ai";
    repo = "openinference";
    tag = "python-openinference-semantic-conventions-v${finalAttrs.version}";
    hash = "sha256-MkgajZknHOw4/qra6uZ99rtpiylpHhOj8tDfLGUSU74=";
  };

  nativeCheckInputs = [
    pytest-asyncio
    pytestCheckHook
  ];

  __structuredAttrs = true;
  build-system = [ hatchling ];
  pyproject = true;
  pythonImportsCheck = [ "openinference.semconv" ];
  sourceRoot = "${finalAttrs.src.name}/python/${finalAttrs.pname}";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "OpenTelemetry Semantic Conventions for AI Observability";
    homepage = "https://github.com/Arize-ai/openinference";
    changelog = "https://github.com/Arize-ai/openinference/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
  };
})

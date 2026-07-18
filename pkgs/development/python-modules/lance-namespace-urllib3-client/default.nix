{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # build-system
  hatchling,
  # dependencies
  pydantic,
  # tests
  pytestCheckHook,
  python-dateutil,
  typing-extensions,
  urllib3,
}:

buildPythonPackage (finalAttrs: {
  pname = "lance-namespace-urllib3-client";
  version = "0.8.6";

  src = fetchFromGitHub {
    owner = "lancedb";
    repo = "lance-namespace";
    tag = "v${finalAttrs.version}";
    hash = "sha256-QYzVsarjTg2arNNuCFbVgtA7rfLTm6AJD3liNr3QuSU=";
  };

  nativeCheckInputs = [
    pytestCheckHook
  ];

  __structuredAttrs = true;

  build-system = [
    hatchling
  ];

  dependencies = [
    pydantic
    python-dateutil
    typing-extensions
    urllib3
  ];

  pyproject = true;
  pythonImportsCheck = [ "lance_namespace_urllib3_client" ];
  sourceRoot = "${finalAttrs.src.name}/python/lance_namespace_urllib3_client";

  meta = {
    description = "Lance namespace OpenAPI specification";
    homepage = "https://github.com/lancedb/lance-namespace/tree/main/python/lance_namespace_urllib3_client";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ GaetanLepage ];
  };
})

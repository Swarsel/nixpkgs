{
  lib,
  fetchFromGitHub,
  azure-core,
  buildPythonPackage,
  isodate,
  setuptools,
  typing-extensions,
}:

buildPythonPackage (finalAttrs: {
  pname = "azure-ai-vision-imageanalysis";
  version = "39.0.0";

  src = fetchFromGitHub {
    owner = "Azure";
    repo = "azure-sdk-for-python";
    tag = "azure-mgmt-containerservice_${finalAttrs.version}";
    hash = "sha256-zufXc8LR4STHi/jjV0bcLsifcHIif2m+3Q/KZlsSkRw=";
  };

  doCheck = false; # cannot import 'devtools_testutils'
  build-system = [ setuptools ];

  dependencies = [
    azure-core
    isodate
    typing-extensions
  ];

  pyproject = true;
  pythonImportsCheck = [ "azure.ai.vision.imageanalysis" ];
  sourceRoot = "${finalAttrs.src.name}/sdk/vision/azure-ai-vision-imageanalysis";

  meta = {
    description = "Azure Image Analysis client library for Python";
    homepage = "https://github.com/Azure/azure-sdk-for-python/tree/main/sdk/vision/azure-ai-vision-imageanalysis";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ sigmanificient ];
  };
})

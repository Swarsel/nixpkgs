{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  llm,
  llm-pdf-to-images,
  pymupdf,
  pytest-asyncio,
  pytestCheckHook,
  setuptools,
  writableTmpDirAsHomeHook,
}:

buildPythonPackage rec {
  pname = "llm-pdf-to-images";
  version = "0.1";

  src = fetchFromGitHub {
    owner = "simonw";
    repo = "llm-pdf-to-images";
    tag = version;
    hash = "sha256-UWtCPdKrGE93NNjCroct5fPhq1pWIkngXXtRb+BHm8k=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    writableTmpDirAsHomeHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    llm
    pymupdf
  ];

  pyproject = true;
  pythonImportsCheck = [ "llm_pdf_to_images" ];
  passthru.tests = llm.mkPluginTest llm-pdf-to-images;

  meta = {
    description = "LLM fragment plugin to load a PDF as a sequence of images";
    homepage = "https://github.com/simonw/llm-pdf-to-images";
    changelog = "https://github.com/simonw/llm-pdf-to-images/releases/tag/${version}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ philiptaron ];
  };
}

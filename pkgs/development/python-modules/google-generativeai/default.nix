{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  google-ai-generativelanguage,
  google-api-core,
  google-api-python-client,
  google-auth,
  protobuf,
  pydantic,
  setuptools,
  tqdm,
  typing-extensions,
}:

buildPythonPackage rec {
  pname = "google-generativeai";
  version = "0.8.6";

  src = fetchFromGitHub {
    owner = "google";
    repo = "generative-ai-python";
    tag = "v${version}";
    hash = "sha256-zUNgQqpGgMyCBhW+Z9EiSJIyuIQh2XhwlCdgrTymCVk=";
  };

  # Issue with the google.ai module. Check with the next release
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    google-ai-generativelanguage
    google-api-core
    google-api-python-client
    google-auth
    protobuf
    pydantic
    tqdm
    typing-extensions
  ];

  pyproject = true;
  pythonImportsCheck = [ "google.generativeai" ];
  pythonRelaxDeps = [ "google-ai-generativelanguage" ];

  meta = {
    description = "Python client library for Google's large language model PaLM API";
    homepage = "https://github.com/google/generative-ai-python";
    changelog = "https://github.com/google/generative-ai-python/releases/tag/${src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
  };
}

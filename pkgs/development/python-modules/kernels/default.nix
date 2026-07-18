{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  huggingface-hub,
  setuptools,
}:
buildPythonPackage rec {
  pname = "kernels";
  version = "0.11.7";

  src = fetchFromGitHub {
    owner = "huggingface";
    repo = "kernels";
    tag = "v${version}";
    hash = "sha256-OUOCC7ViRWqRZIUpK31ItWsNc0F87dBpAg/Lql1LWp4=";
  };

  # Tests require pervasive internet access
  doCheck = false;

  build-system = [
    setuptools
  ];

  dependencies = [
    huggingface-hub
  ];

  pyproject = true;
  pythonImportsCheck = [ "kernels" ];

  meta = {
    description = "Load compute kernels from the Huggingface Hub";
    homepage = "https://github.com/huggingface/kernels";
    changelog = "https://github.com/huggingface/kernels/releases/tag/${src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ osbm ];
  };
}

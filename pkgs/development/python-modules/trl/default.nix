{
  lib,
  fetchFromGitHub,
  # dependencies
  accelerate,
  buildPythonPackage,
  datasets,
  packaging,
  rich,
  # build-system
  setuptools,
  transformers,
}:

buildPythonPackage (finalAttrs: {
  pname = "trl";
  version = "0.24.0";

  src = fetchFromGitHub {
    owner = "huggingface";
    repo = "trl";
    tag = "v${finalAttrs.version}";
    hash = "sha256-t0wOuEKlcZzFlQeS4PYHykFsz+43hYc0gJ9u4emr8HI=";
  };

  # Many tests require internet access.
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    accelerate
    datasets
    packaging
    rich
    transformers
  ];

  pyproject = true;
  pythonImportsCheck = [ "trl" ];

  meta = {
    description = "Train transformer language models with reinforcement learning";
    homepage = "https://github.com/huggingface/trl";
    changelog = "https://github.com/huggingface/trl/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ hoh ];
  };
})

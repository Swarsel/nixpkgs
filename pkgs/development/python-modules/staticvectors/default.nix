{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # dependencies
  huggingface-hub,
  numpy,
  safetensors,
  # build-system
  setuptools,
  tqdm,
}:

buildPythonPackage rec {
  pname = "staticvectors";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "neuml";
    repo = "staticvectors";
    tag = "v${version}";
    hash = "sha256-p3m22qLxQYma0WtkTE/GzHXkxNHjatqLOdeHh4vtyVc=";
  };

  # no tests
  doCheck = false;

  build-system = [
    setuptools
  ];

  dependencies = [
    huggingface-hub
    numpy
    safetensors
    tqdm
  ];

  pyproject = true;
  pythonImportsCheck = [ "staticvectors" ];

  meta = {
    description = "Work with static vector models";
    homepage = "https://github.com/neuml/staticvectors";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ GaetanLepage ];
  };
}

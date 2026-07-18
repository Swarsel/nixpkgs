{
  lib,
  fetchFromGitHub,
  aistudio-sdk,
  buildPythonPackage,
  chardet,
  colorlog,
  filelock,
  gputil,
  huggingface-hub,
  modelscope,
  nix-update-script,
  numpy,
  pandas,
  pillow,
  prettytable,
  py-cpuinfo,
  pydantic,
  pyyaml,
  requests,
  ruamel-yaml,
  setuptools,
  setuptools-scm,
  typing-extensions,
  ujson,
}:

buildPythonPackage (finalAttrs: {
  pname = "paddlex";
  version = "3.7.2";

  src = fetchFromGitHub {
    owner = "PaddlePaddle";
    repo = "PaddleX";
    tag = "v${finalAttrs.version}";
    hash = "sha256-E9WvXQTqpD9y/1tSNjOEws1ELRp65w9hTgeVq1lLBvI=";
  };

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    chardet
    colorlog
    filelock
    numpy
    pandas
    pillow
    prettytable
    py-cpuinfo
    pydantic
    pyyaml
    requests
    ruamel-yaml
    typing-extensions
    ujson
    gputil
    huggingface-hub
    modelscope
    aistudio-sdk
  ];

  pyproject = true;

  pythonRelaxDeps = [
    "pyyaml"
    "numpy"
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "All-in-One Development Tool based on PaddlePaddle";
    homepage = "https://github.com/PaddlePaddle/PaddleX";
    changelog = "https://github.com/PaddlePaddle/PaddleX/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    maintainers = [ ];

    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "aarch64-darwin"
    ];
  };
})

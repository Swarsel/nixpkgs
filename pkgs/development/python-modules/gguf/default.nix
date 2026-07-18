{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  nix-update-script,
  # dependencies
  numpy,
  # build-system
  poetry-core,
  pyside6,
  # tests
  pytestCheckHook,
  pyyaml,
  requests,
  tqdm,
}:

buildPythonPackage (finalAttrs: {
  pname = "gguf";
  version = "9967";

  src = fetchFromGitHub {
    owner = "ggml-org";
    repo = "llama.cpp";
    tag = "b${finalAttrs.version}";
    hash = "sha256-HgptebnnT3xOU26/UJCqQ6FSrhcoybju7SKUy4pLOKA=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ poetry-core ];

  dependencies = [
    numpy
    pyyaml
    requests
    tqdm
  ];

  optional-dependencies = {
    gui = [ pyside6 ];
  };

  pyproject = true;
  pythonImportsCheck = [ "gguf" ];
  sourceRoot = "${finalAttrs.src.name}/gguf-py";

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version-regex"
      "b(.*)"
    ];
  };

  meta = {
    description = "Module for writing binary files in the GGUF format";
    homepage = "https://ggml.ai/";
    changelog = "https://github.com/ggml-org/llama.cpp/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      mitchmindtree
      sarahec
    ];

    downloadPage = "https://github.com/ggml-org/llama.cpp/releases";
  };
})

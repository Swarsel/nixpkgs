{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # build-system
  cmake,
  pybind11,
  # tests
  pytestCheckHook,
  replaceVars,
  # dependencies
  sentencepiece,
  setuptools,
  tiktoken,
  tokenizers,
  transformers,
}:

let
  # https://github.com/meta-pytorch/tokenizers/blob/v<VERSION>/CMakeLists.txt#L174-L175
  pybind11-src = fetchFromGitHub {
    hash = "sha256-SNLdtrOjaC3lGHN9MAqTf51U9EzNKQLyTMNPe0GcdrU=";
    owner = "pybind";
    repo = "pybind11";
    tag = "v2.13.6";
  };
in
buildPythonPackage (finalAttrs: {
  pname = "pytorch-tokenizers";
  version = "1.3.0";

  src = fetchFromGitHub {
    owner = "meta-pytorch";
    repo = "tokenizers";
    tag = "v${finalAttrs.version}";
    hash = "sha256-1G6mDUSwy4KXKgdtEimj9rrQDonGHdo8R8DvPQppvwE=";
    fetchSubmodules = true;
  };

  patches = [
    (replaceVars ./dont-fetch-pybind11.patch {
      pybind11 = pybind11-src;
    })
    # error: ‘uint32_t’ does not name a type
    ./add-missing-cstdint-sentencepiece.patch
  ];

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail '"pip>=23",' "" \
      --replace-fail '"pytest",' ""
  '';

  # pkgs/by-name/cm/cmake/setup-hook.sh
  preBuild = ''
    if ! [[ -v enableParallelBuilding ]]; then
        enableParallelBuilding=1
        echo "cmake: enabled parallel building"
    fi
    if [[ "$enableParallelBuilding" -ne 0 ]]; then
        export CMAKE_BUILD_PARALLEL_LEVEL=$NIX_BUILD_CORES
    fi
  '';

  nativeCheckInputs = [
    pytestCheckHook
    transformers
  ];

  preCheck = ''
    rm -rf pytorch_tokenizers
  '';

  __structuredAttrs = true;

  build-system = [
    cmake
    pybind11
    setuptools
  ];

  dependencies = [
    sentencepiece
    tiktoken
    tokenizers
  ];

  disabledTestPaths = [
    # Require downloading models from huggingface
    "test/test_hf_tokenizer.py"
  ];

  dontUseCmakeConfigure = true;
  pyproject = true;

  pythonImportsCheck = [
    "pytorch_tokenizers"
    "pytorch_tokenizers.pytorch_tokenizers_cpp"
  ];

  meta = {
    description = "C++ implementations for various tokenizers (sentencepiece, tiktoken, etc.)";
    homepage = "https://github.com/meta-pytorch/tokenizers";
    changelog = "https://github.com/meta-pytorch/tokenizers/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ GaetanLepage ];
  };
})

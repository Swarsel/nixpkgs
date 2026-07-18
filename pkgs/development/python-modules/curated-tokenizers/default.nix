{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cython,
  pytestCheckHook,
  regex,
  setuptools,
}:

buildPythonPackage rec {
  pname = "curated-tokenizers";
  version = "2.0.0";

  src = fetchFromGitHub {
    owner = "explosion";
    repo = "curated-tokenizers";
    tag = "v${version}";
    hash = "sha256-VkDV/9c5b8TzYlthCZ38ufbrne4rihtkmkZ/gyAQXLE=";
    fetchSubmodules = true;
  };

  # Fix gcc15 build failures due to missing <cstdint>
  postPatch = ''
    sed -i '1i #include <cstdint>' sentencepiece/src/sentencepiece_processor.h
  '';

  nativeCheckInputs = [
    pytestCheckHook
  ];

  preCheck = ''
    # avoid local paths, relative imports wont resolve correctly
    mv curated_tokenizers/tests tests
    rm -r curated_tokenizers
  '';

  build-system = [
    cython
    setuptools
  ];

  dependencies = [
    regex
  ];

  # Explicitly set the path to avoid running vendored
  # sentencepiece tests.
  enabledTestPaths = [ "tests" ];
  pyproject = true;
  pythonImportsCheck = [ "curated_tokenizers" ];

  meta = {
    description = "Lightweight piece tokenization library";
    homepage = "https://github.com/explosion/curated-tokenizers";
    changelog = "https://github.com/explosion/curated-tokenizers/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ danieldk ];
  };
}

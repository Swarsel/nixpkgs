{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  jamo,
  marisa-trie,
  panphon,
  regex,
  requests,
  setuptools,
  setuptools-scm,
  unittestCheckHook,
}:

buildPythonPackage rec {
  pname = "epitran";
  version = "1.35.2";

  src = fetchFromGitHub {
    owner = "dmort27";
    repo = "epitran";
    tag = "v${version}";
    hash = "sha256-O9AzL+snaL0WawsL00v0nnuUZqqC0gAmrlJWLsDnfyU=";
  };

  nativeCheckInputs = [ unittestCheckHook ];

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    jamo
    regex
    panphon
    marisa-trie
    requests
  ];

  pyproject = true;

  pythonImportsCheck = [
    "epitran"
    "epitran.backoff"
    "epitran.vector"
  ];

  unittestFlagsArray = [
    "-s"
    "test"
  ];

  meta = {
    description = "Tools for transcribing languages into IPA";
    homepage = "https://github.com/dmort27/epitran";
    changelog = "https://github.com/dmort27/epitran/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ vizid ];
  };
}

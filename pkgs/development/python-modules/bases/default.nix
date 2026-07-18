{
  lib,
  fetchFromGitHub,
  # for tests
  base58,
  buildPythonPackage,
  pytestCheckHook,
  setuptools,
  setuptools-scm,
  typing-extensions,
  typing-validation,
  wheel,
}:

buildPythonPackage rec {
  pname = "bases";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "hashberg-io";
    repo = "bases";
    tag = "v${version}";
    hash = "sha256-CRXVxT9uYud1CKRcdRAD0OX5sTAttrUO9E4BaavTe6A=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    base58
  ];

  build-system = [
    setuptools
    wheel
    setuptools-scm
  ];

  dependencies = [
    typing-extensions
    typing-validation
  ];

  pyproject = true;

  pythonImportsCheck = [
    "bases"
    "bases.alphabet"
    "bases.alphabet.abstract"
    "bases.alphabet.range_alphabet"
    "bases.alphabet.string_alphabet"
    "bases.encoding"
    "bases.encoding.base"
    "bases.encoding.block"
    "bases.encoding.errors"
    "bases.encoding.fixchar"
    "bases.encoding.simple"
    "bases.encoding.zeropad"
    "bases.random"
  ];

  meta = {
    description = "Python library for general Base-N encodings";
    homepage = "https://github.com/hashberg-io/bases";
    changelog = "https://github.com/hashberg-io/bases/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.vizid ];
  };
}

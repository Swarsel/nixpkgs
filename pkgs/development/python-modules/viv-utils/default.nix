{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  funcy,
  intervaltree,
  pefile,
  pytest-sugar,
  pytestCheckHook,
  python-flirt,
  setuptools-scm,
  typing-extensions,
  vivisect,
}:

buildPythonPackage (finalAttrs: {
  pname = "viv-utils";
  version = "0.8.1";

  src = fetchFromGitHub {
    owner = "williballenthin";
    repo = "viv-utils";
    tag = "v${finalAttrs.version}";
    hash = "sha256-YyD6CFA8lhc1XU7pckKv3th422ssYZkRJ/JfQD5e65c=";
  };

  nativeCheckInputs = [
    pytest-sugar
    pytestCheckHook
  ];

  build-system = [ setuptools-scm ];

  dependencies = [
    funcy
    intervaltree
    pefile
    typing-extensions
    vivisect
  ];

  pyproject = true;
  pythonImportsCheck = [ "viv_utils" ];

  passthru = {
    optional-dependencies = {
      flirt = [ python-flirt ];
    };
  };

  meta = {
    description = "Utilities for working with vivisect";
    homepage = "https://github.com/williballenthin/viv-utils";
    changelog = "https://github.com/williballenthin/viv-utils/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    maintainers = [ ];
  };
})

{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  dissect-cstruct,
  dissect-util,
  pycryptodome,
  pytestCheckHook,
  pythonAtLeast,
  setuptools,
  setuptools-scm,
}:

buildPythonPackage (finalAttrs: {
  pname = "dissect-evidence";
  version = "3.13";

  src = fetchFromGitHub {
    owner = "fox-it";
    repo = "dissect.evidence";
    tag = finalAttrs.version;
    hash = "sha256-oix0CSsVqBM5udzePa/leabw5sOB8VfLFTB9e46sTD0=";
    fetchLFS = true;
  };

  nativeCheckInputs = [
    pytestCheckHook
  ]
  ++ lib.concatAttrValues finalAttrs.passthru.optional-dependencies;

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    dissect-cstruct
    dissect-util
  ];

  disabledTests = lib.optionals (pythonAtLeast "3.14") [
    # https://github.com/fox-it/dissect.evidence/issues/46
    "test_ewf"
  ];

  optional-dependencies = {
    full = [ pycryptodome ];
  };

  pyproject = true;
  pythonImportsCheck = [ "dissect.evidence" ];

  meta = {
    description = "Dissect module implementing a parsers for various forensic evidence file containers";
    homepage = "https://github.com/fox-it/dissect.evidence";
    changelog = "https://github.com/fox-it/dissect.evidence/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ fab ];
  };
})

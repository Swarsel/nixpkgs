{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  pyyaml,
  setuptools,
  setuptools-scm,
}:

buildPythonPackage (finalAttrs: {
  pname = "riscv-model";
  version = "0.6.6";

  src = fetchFromGitHub {
    owner = "wallento";
    repo = "riscv-python-model";
    tag = finalAttrs.version;
    hash = "sha256-H4N9Z8aK/xV5gCCdsL+oiR+XQfYtCfBRBGLqvuztX+o=";
  };

  nativeCheckInputs = [
    pytestCheckHook
  ];

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    pyyaml
  ];

  pyproject = true;

  pythonImportsCheck = [
    "riscvmodel"
    "riscvmodel.insn"
    "riscvmodel.variant"
  ];

  meta = {
    description = "Formal RISC-V architecture model in Python";
    homepage = "https://github.com/wallento/riscv-python-model";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.gonsolo ];
    platforms = lib.platforms.all;
  };
})

{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # dependencies
  opt-einsum,
  # tests
  pytestCheckHook,
  # build-system
  setuptools,
  torch,
}:

buildPythonPackage (finalAttrs: {
  pname = "opt-einsum-fx";
  version = "0.1.4";

  src = fetchFromGitHub {
    owner = "Linux-cpp-lisp";
    repo = "opt_einsum_fx";
    tag = "v${finalAttrs.version}";
    hash = "sha256-HamDghqmdX4Q+4zXQvCly588p3TaYFCSnzgEKLVMXSo=";
  };

  nativeCheckInputs = [
    pytestCheckHook
  ];

  __structuredAttrs = true;

  build-system = [
    setuptools
  ];

  dependencies = [
    opt-einsum
    torch
  ];

  pyproject = true;
  pythonImportsCheck = [ "opt_einsum_fx" ];

  meta = {
    description = "Einsum optimization using opt_einsum and PyTorch FX graph rewriting";
    homepage = "https://github.com/Linux-cpp-lisp/opt_einsum_fx";
    changelog = "https://github.com/Linux-cpp-lisp/opt_einsum_fx/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ GaetanLepage ];
  };
})

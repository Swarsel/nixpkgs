{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  # tests
  llvmPackages,
  pytestCheckHook,
  # dependencies
  pyvers,
  # tests
  setuptools,
  torch,
}:

buildPythonPackage (finalAttrs: {
  pname = "hoptorch";
  version = "0.1.4";

  src = fetchFromGitHub {
    owner = "vmoens";
    repo = "hoptorch";
    tag = "v${finalAttrs.version}";
    hash = "sha256-rhX81MidgltQ2YQtUdYoK1Qtz7N7x9MpZIKDlZzN+vg=";
  };

  nativeCheckInputs = [
    pytestCheckHook
  ];

  __structuredAttrs = true;

  build-system = [
    setuptools
  ];

  dependencies = [
    pyvers
    torch
  ];

  pyproject = true;
  pythonImportsCheck = [ "hoptorch" ];

  meta = {
    description = "Small compatibility package for PyTorch higher-order operators";
    homepage = "https://github.com/vmoens/hoptorch";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ GaetanLepage ];
  };
})

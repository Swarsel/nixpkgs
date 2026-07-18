{
  lib,
  fetchFromGitHub,
  # dependencies
  argparse-dataclass,
  buildPythonPackage,
  configargparse,
  fetchpatch,
  # tests
  pytestCheckHook,
  # build-system
  setuptools,
  snakemake,
  # passthru
  snakemake-interface-common,
}:

buildPythonPackage (finalAttrs: {
  pname = "snakemake-interface-common";
  version = "1.23.0";

  src = fetchFromGitHub {
    owner = "snakemake";
    repo = "snakemake-interface-common";
    tag = "v${finalAttrs.version}";
    hash = "sha256-D3vktJmn1CifdiEg5UPGpBuuigEIb+ja4yklHZA6ytQ=";
  };

  patches = [
    # Upstream PR: https://github.com/snakemake/snakemake-interface-common/pull/89
    (fetchpatch {
      hash = "sha256-mZ03mx7W5XpdNzr1aNVyQm7/hPdD7yuYqk7DCR9y7Fw=";
      name = "relax-packaging-dependency.patch";
      url = "https://github.com/snakemake/snakemake-interface-common/commit/d585b5c0c7c0ec0df60a1a26d5d413f3ee88e63f.patch";
    })
  ];

  # Circular dependency with snakemake
  doCheck = false;

  nativeCheckInputs = [
    pytestCheckHook
    snakemake
  ];

  __structuredAttrs = true;

  build-system = [
    setuptools
  ];

  dependencies = [
    argparse-dataclass
    configargparse
  ];

  enabledTestPaths = [ "tests/tests.py" ];
  pyproject = true;
  pythonImportsCheck = [ "snakemake_interface_common" ];

  passthru.tests.pytest = snakemake-interface-common.overridePythonAttrs {
    doCheck = true;
  };

  meta = {
    description = "Common functions and classes for Snakemake and its plugins";
    homepage = "https://github.com/snakemake/snakemake-interface-common";
    changelog = "https://github.com/snakemake/snakemake-interface-common/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ veprbl ];
  };
})

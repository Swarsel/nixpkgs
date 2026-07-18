{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # build-system
  cython,
  # tests
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "reedsolo";
  version = "1.7.0";

  # Pypi does not have the tests
  src = fetchFromGitHub {
    owner = "tomerfiliba";
    repo = "reedsolomon";
    tag = "v${finalAttrs.version}";
    hash = "sha256-nzdD1oGXHSeGDD/3PpQQEZYGAwn9ahD2KNYGqpgADh0=";
  };

  nativeBuildInputs = [
    cython
    setuptools
  ];

  nativeCheckInputs = [ pytestCheckHook ];

  disabledTestPaths = [
    "tests/test_creedsolo.py" # TODO: package creedsolo
  ];

  pyproject = true;

  meta = {
    description = "Pure-python universal errors-and-erasures Reed-Solomon Codec";
    homepage = "https://github.com/tomerfiliba/reedsolomon";
    license = lib.licenses.publicDomain;
    maintainers = with lib.maintainers; [ yorickvp ];
  };
})

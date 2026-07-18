{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pip,
  pylint,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "astroid";
  version = "4.0.3"; # Check whether the version is compatible with pylint

  src = fetchFromGitHub {
    owner = "PyCQA";
    repo = "astroid";
    tag = "v${finalAttrs.version}";
    hash = "sha256-5p1xY6EWviSgmrLVOx3w7RcG/Vpx+sUtVndoxXrIFTQ=";
  };

  nativeCheckInputs = [
    pip
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  disabledTestPaths = [
    # requires mypy
    "tests/test_raw_building.py"
  ];

  disabledTests = [
    # UserWarning: pkg_resources is deprecated as an API. See https://setuptools.pypa.io/en/latest/pkg_resources.html.
    "test_identify_old_namespace_package_protocol"
  ];

  pyproject = true;

  passthru.tests = {
    inherit pylint;
  };

  meta = {
    description = "Abstract syntax tree for Python with inference support";
    homepage = "https://github.com/PyCQA/astroid";
    changelog = "https://github.com/PyCQA/astroid/blob/${finalAttrs.src.tag}/ChangeLog";
    license = lib.licenses.lgpl21Plus;
    maintainers = with lib.maintainers; [ GaetanLepage ];
  };
})

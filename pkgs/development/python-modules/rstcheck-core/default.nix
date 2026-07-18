{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  docutils,
  mock,
  pydantic,
  pytest-mock,
  pytestCheckHook,
  setuptools,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "rstcheck-core";
  version = "1.3.0";

  src = fetchFromGitHub {
    owner = "rstcheck";
    repo = "rstcheck-core";
    tag = "v${version}";
    hash = "sha256-ZQgbraIQgfhJM4JYfZjPZcMswOddGQb8pdHjTBo53jk=";
  };

  env = {
    NIX_CFLAGS_COMPILE = lib.optionalString stdenv.cc.isClang "-Wno-strict-prototypes";
  };

  nativeCheckInputs = [
    mock
    pytest-mock
    pytestCheckHook
  ];

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    docutils
    pydantic
  ];

  disabledTests = [
    # https://github.com/rstcheck/rstcheck-core/issues/84
    "test_check_yaml_returns_error_on_bad_code_block"
  ];

  pyproject = true;
  pythonImportsCheck = [ "rstcheck_core" ];

  meta = {
    description = "Library for checking syntax of reStructuredText";
    homepage = "https://github.com/rstcheck/rstcheck-core";
    changelog = "https://github.com/rstcheck/rstcheck-core/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
}

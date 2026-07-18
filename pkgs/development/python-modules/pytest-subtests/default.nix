{
  lib,
  fetchFromGitHub,
  # dependencies
  attrs,
  buildPythonPackage,
  pytest,
  # build-system
  setuptools,
  setuptools-scm,
}:

buildPythonPackage (finalAttrs: {
  pname = "pytest-subtests";
  version = "0.15.0";

  src = fetchFromGitHub {
    owner = "pytest-dev";
    repo = "pytest-subtests";
    tag = "v${finalAttrs.version}";
    hash = "sha256-KJbTxhheEkvH/Xnje45dSb57526bVoi8N6GSKfUfCYA=";
  };

  # The self-tests assert on exact pytest terminal output. pytest 9 ships its
  # own bundled subtests support and changed how subtest failures are reported,
  # so these output-matching tests no longer match. The plugin itself works.
  doCheck = false;
  __structuredAttrs = true;

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    attrs
    pytest
  ];

  pyproject = true;
  pythonImportsCheck = [ "pytest_subtests" ];

  meta = {
    description = "Unittest subTest() support and subtests fixture";
    homepage = "https://github.com/pytest-dev/pytest-subtests";
    changelog = "https://github.com/pytest-dev/pytest-subtests/blob/${finalAttrs.src.tag}/CHANGELOG.rst";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ GaetanLepage ];
  };
})

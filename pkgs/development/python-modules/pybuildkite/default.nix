{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # tests
  pytest-cov-stub,
  pytestCheckHook,
  # dependencies
  requests,
  # build-system
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "pybuildkite";
  version = "1.3.0";

  src = fetchFromGitHub {
    owner = "pyasi";
    repo = "pybuildkite";
    tag = "v${finalAttrs.version}";
    hash = "sha256-yMUZUkERfxMUkVVYNkPiFf9wrZR6d5+gqW/P6ri2Q1I=";
  };

  nativeCheckInputs = [
    pytest-cov-stub
    pytestCheckHook
  ];

  __structuredAttrs = true;

  build-system = [
    setuptools
  ];

  dependencies = [
    requests
  ];

  pyproject = true;
  pythonImportsCheck = [ "pybuildkite" ];

  meta = {
    description = "Python library for the Buildkite API";
    homepage = "https://github.com/pyasi/pybuildkite";
    changelog = "https://github.com/pyasi/pybuildkite/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ GaetanLepage ];
  };
})

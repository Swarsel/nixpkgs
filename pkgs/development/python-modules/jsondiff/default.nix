{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # tests
  hypothesis,
  pytestCheckHook,
  # dependencies
  pyyaml,
  # build-system
  setuptools,
  setuptools-scm,
}:

buildPythonPackage (finalAttrs: {
  pname = "jsondiff";
  version = "2.2.1";

  src = fetchFromGitHub {
    owner = "xlwings";
    repo = "jsondiff";
    tag = finalAttrs.version;
    hash = "sha256-0EnI7f5t7Ftl/8UcsRdA4iVQ78mxvPucCJjFJ8TMwww=";
  };

  nativeCheckInputs = [
    hypothesis
    pytestCheckHook
  ];

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [ pyyaml ];
  pyproject = true;

  meta = {
    description = "Diff JSON and JSON-like structures in Python";
    homepage = "https://github.com/ZoomerAnalytics/jsondiff";
    license = lib.licenses.mit;
    mainProgram = "jdiff";
  };
})

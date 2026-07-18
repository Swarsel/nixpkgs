{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cython,
  numpy,
  # tests
  pytestCheckHook,
  # build-system
  setuptools,
  # dependencies
  torch,
}:

buildPythonPackage rec {
  pname = "monotonic-alignment-search";
  version = "0.2.1";

  src = fetchFromGitHub {
    owner = "eginhard";
    repo = "monotonic_alignment_search";
    tag = "v${version}";
    hash = "sha256-XsQDRsgwwlZAmxpsISgNYbrgnMOQIVNvzJV4ZWxswCY=";
  };

  nativeCheckInputs = [
    pytestCheckHook
  ];

  build-system = [
    setuptools
    cython
    numpy
  ];

  dependencies = [
    numpy
    torch
  ];

  pyproject = true;
  pythonImportsCheck = [ "monotonic_alignment_search" ];

  meta = {
    description = "Monotonically align text and speech";
    homepage = "https://github.com/eginhard/monotonic_alignment_search";
    changelog = "https://github.com/eginhard/monotonic_alignment_search/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ jbgi ];
  };
}

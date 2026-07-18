{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hypothesis,
  pytest-httpserver,
  pytest-xdist,
  pytestCheckHook,
  requests,
  rfc3986,
  setuptools,
  wheel,
}:

buildPythonPackage rec {
  pname = "jschon";
  version = "0.11.1";

  src = fetchFromGitHub {
    owner = "marksparkza";
    repo = "jschon";
    rev = "v${version}";
    hash = "sha256-uOvEIEUEILsoLuV5U9AJCQAlT4iHQhsnSt65gfCiW0k=";
    fetchSubmodules = true;
  };

  nativeCheckInputs = [
    pytestCheckHook
    hypothesis
    requests
    pytest-httpserver
    #pytest-benchmark # not needed for distribution
    pytest-xdist # not used upstream, but massive speedup
  ];

  # used in checks
  __darwinAllowLocalNetworking = true;

  build-system = [
    setuptools
    wheel
  ];

  dependencies = [
    rfc3986
  ];

  disabledTestPaths = [
    "tests/test_benchmarks.py"
  ];

  disabledTests = [
    # flaky, timing sensitive
    "test_keyword_dependency_resolution"
  ];

  pyproject = true;

  pythonImportsCheck = [
    "jschon"
    "jschon.catalog"
    "jschon.vocabulary"
    "jschon.exc"
    "jschon.exceptions"
    "jschon.formats"
    "jschon.json"
    "jschon.jsonpatch"
    "jschon.jsonpointer"
    "jschon.jsonschema"
    "jschon.output"
    "jschon.uri"
    "jschon.utils"
  ];

  meta = {
    description = "Object-oriented JSON Schema implementation for Python";
    homepage = "https://github.com/marksparkza/jschon";
    changelog = "https://github.com/marksparkza/jschon/blob/${src.rev}/CHANGELOG.rst";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ pbsds ];
  };
}

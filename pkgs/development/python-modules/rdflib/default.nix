{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  # extras: html
  html5lib,
  # extras: networkx
  networkx,
  # tests
  pip,
  # builds
  poetry-core,
  # propagates
  pyparsing,
  pytest-cov-stub,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "rdflib";
  version = "7.5.0";

  src = fetchFromGitHub {
    owner = "RDFLib";
    repo = "rdflib";
    tag = version;
    hash = "sha256-jZ5mbTz/ra/ZHAFyMmtqaM4RZw851gfTCBCRuPcGeYA=";
  };

  nativeCheckInputs = [
    pip
    pytest-cov-stub
    pytestCheckHook
    setuptools
  ]
  ++ optional-dependencies.networkx
  ++ optional-dependencies.html;

  __darwinAllowLocalNetworking = true;
  build-system = [ poetry-core ];

  dependencies = [
    pyparsing
  ];

  disabledTestPaths = [
    # requires network access
    "rdflib/__init__.py::rdflib"
    "test/jsonld/test_onedotone.py::test_suite"
  ];

  disabledTests = [
    # Requires network access
    "test_service"
    "testGuessFormatForParse"
    "test_infix_owl_example1"
    "test_context"
    "test_example"
    "test_guess_format_for_parse"
    "rdflib.extras.infixowl"
    # Upstream don't seem worried about these two tests failing
    # https://github.com/RDFLib/rdflib/issues/2649#issuecomment-2443482119
    "test_sparqleval"
    "test_parser"
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    # Require loopback network access
    "TestGraphHTTP"
  ];

  optional-dependencies = {
    html = [ html5lib ];
    networkx = [ networkx ];
  };

  pyproject = true;
  pythonImportsCheck = [ "rdflib" ];

  meta = {
    description = "Python library for working with RDF";
    homepage = "https://rdflib.readthedocs.io";
    changelog = "https://github.com/RDFLib/rdflib/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.bsd3;
    maintainers = [ ];
  };
}

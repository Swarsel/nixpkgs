{
  lib,
  fetchFromGitHub,
  attrs,
  babel,
  buildPythonPackage,
  frictionless,
  isodate,
  jsonschema,
  language-tags,
  pytest-cov-stub,
  pytest-mock,
  pytestCheckHook,
  python-dateutil,
  rdflib,
  requests,
  requests-mock,
  rfc3986,
  setuptools,
  termcolor,
  uritemplate,
}:

buildPythonPackage (finalAttrs: {
  pname = "csvw";
  version = "3.7.0";

  src = fetchFromGitHub {
    owner = "cldf";
    repo = "csvw";
    tag = "v${finalAttrs.version}";
    hash = "sha256-HftvI4xJy/MX0WTIFNyZqNqIJIlHsWhhURpeQ1XqrT0=";
  };

  postPatch = ''
    substituteInPlace src/csvw/__main__.py \
      --replace-fail "'frictionless'" "'${lib.getExe frictionless}'"
  '';

  nativeCheckInputs = [
    pytestCheckHook
    pytest-cov-stub
    pytest-mock
    requests-mock
  ];

  build-system = [ setuptools ];

  dependencies = [
    attrs
    babel
    frictionless
    isodate
    jsonschema
    python-dateutil
    requests
    rdflib
    rfc3986
    uritemplate
    termcolor
    language-tags
  ];

  disabledTestPaths = [
    # Missing manifest-json.jsonld
    "tests/test_conformance.py"
  ];

  disabledTests = [
    # this test is flaky on darwin because it depends on the resolution of filesystem mtimes
    # https://github.com/cldf/csvw/blob/45584ad63ff3002a9b3a8073607c1847c5cbac58/tests/test_db.py#L257
    "test_write_file_exists"
  ];

  pyproject = true;
  pythonImportsCheck = [ "csvw" ];
  pythonRelaxDeps = [ "rfc3986" ];

  meta = {
    description = "CSV on the Web";
    homepage = "https://github.com/cldf/csvw";
    license = lib.licenses.asl20;
    maintainers = [ ];
  };
})

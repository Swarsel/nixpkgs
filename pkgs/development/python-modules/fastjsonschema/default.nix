{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "fastjsonschema";
  version = "2.21.2";

  src = fetchFromGitHub {
    owner = "horejsek";
    repo = "python-fastjsonschema";
    rev = "v${version}";
    hash = "sha256-EV7/vPYeJSG2uTLpENso9WhcR98/ZTbanKffJfmfZz4=";
    fetchSubmodules = true;
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];

  disabledTestPaths = [
    # fastjsonschema.exceptions.JsonSchemaDefinitionException: Unknown format uuid/duration
    "tests/json_schema/test_draft2019.py::test"
  ];

  disabledTests = [
    "benchmark"
    # these tests require network access
    "remote"
    "ref"
    "definitions"
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    "test_compile_to_code_custom_format" # cannot import temporary module created during test
  ];

  pyproject = true;
  pythonImportsCheck = [ "fastjsonschema" ];

  meta = {
    description = "JSON schema validator for Python";
    homepage = "https://horejsek.github.io/python-fastjsonschema/";
    license = lib.licenses.bsd3;
    maintainers = [ ];
    downloadPage = "https://github.com/horejsek/python-fastjsonschema";
  };
}

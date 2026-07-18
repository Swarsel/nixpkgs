{
  lib,
  fetchFromGitHub,
  # dependencies
  bitstruct,
  buildPythonPackage,
  diskcache,
  # optional-dependencies
  prompt-toolkit,
  pyparsing,
  # tests
  pytest-xdist,
  pytestCheckHook,
  # build-system
  setuptools,
  versionCheckHook,
}:

buildPythonPackage rec {
  pname = "asn1tools";
  version = "0.167.0";

  src = fetchFromGitHub {
    owner = "eerimoq";
    repo = "asn1tools";
    tag = version;
    hash = "sha256-86bdBYlAVJfd3EY8s0t6ZDRA/qZVWuHD4Jxa1n1Ke5E=";
  };

  nativeCheckInputs = [
    pytest-xdist
    pytestCheckHook
    versionCheckHook
  ]
  ++ lib.concatAttrValues optional-dependencies;

  build-system = [ setuptools ];

  dependencies = [
    bitstruct
    pyparsing
  ];

  disabledTests = [
    # assert exact error message of pyparsing which changed and no longer matches
    # https://github.com/eerimoq/asn1tools/issues/167
    "test_parse_error"

    # IndexError: string index out of range
    # https://github.com/eerimoq/asn1tools/issues/191
    "test_c_source"
    "test_command_line_generate_c_source_oer"
    "test_missing_parameterized_value"
    "test_parse_parameterization"
    # SystemExit: error: string index out of range
    "test_command_line_generate_c_source_uper"
    "test_command_line_generate_rust_source_uper"
  ];

  optional-dependencies = {
    cache = [ diskcache ];
    shell = [ prompt-toolkit ];
  };

  pyproject = true;
  pythonImportsCheck = [ "asn1tools" ];

  meta = {
    description = "ASN.1 parsing, encoding and decoding";
    homepage = "https://github.com/eerimoq/asn1tools";
    changelog = "https://github.com/eerimoq/asn1tools/releases/tag/${version}";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "asn1tools";
  };
}

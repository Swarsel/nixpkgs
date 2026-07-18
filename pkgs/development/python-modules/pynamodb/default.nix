{
  lib,
  fetchFromGitHub,
  blinker,
  botocore,
  buildPythonPackage,
  freezegun,
  pytest-env,
  pytest-mock,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "pynamodb";
  version = "6.1.0";

  src = fetchFromGitHub {
    owner = "pynamodb";
    repo = "PynamoDB";
    tag = version;
    hash = "sha256-i4oxZO3gBVc2PMFSISeytaO8YrzYR9YuUMxrEqrg2c4=";
  };

  nativeCheckInputs = [
    freezegun
    pytest-env
    pytest-mock
    pytestCheckHook
  ]
  ++ optional-dependencies.signal;

  build-system = [ setuptools ];
  dependencies = [ botocore ];

  disabledTests = [
    # Tests requires credentials or network access
    "test_binary_attribute_update"
    "test_binary_set_attribute_update"
    "test_connection_integration"
    "test_make_api_call__happy_path"
    "test_model_integration"
    "test_sign_request"
    "test_table_integration"
    "test_transact"
    # require a local dynamodb instance
    "test_create_table"
    "test_create_table__incompatible_indexes"
    # https://github.com/pynamodb/PynamoDB/issues/1265
    "test_connection_make_api_call__binary_attributes"
  ];

  optional-dependencies = {
    signal = [ blinker ];
  };

  pyproject = true;
  pythonImportsCheck = [ "pynamodb" ];

  meta = {
    description = "Interface for Amazon’s DynamoDB";

    longDescription = ''
      DynamoDB is a great NoSQL service provided by Amazon, but the API is
      verbose. PynamoDB presents you with a simple, elegant API.
    '';

    homepage = "http://jlafon.io/pynamodb.html";
    changelog = "https://github.com/pynamodb/PynamoDB/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}

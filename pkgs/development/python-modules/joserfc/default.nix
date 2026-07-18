{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # dependencies
  cryptography,
  pycryptodome,
  # tests
  pytestCheckHook,
  # build-system
  setuptools,
}:

buildPythonPackage rec {
  pname = "joserfc";
  version = "1.6.9";

  src = fetchFromGitHub {
    owner = "authlib";
    repo = "joserfc";
    tag = version;
    hash = "sha256-Ge1r34GVmpJ9h5GtRkPd0mkV7HuLf7D31ikuPAnpkuY=";
  };

  nativeCheckInputs = [ pytestCheckHook ] ++ lib.concatAttrValues optional-dependencies;
  build-system = [ setuptools ];
  dependencies = [ cryptography ];

  disabledTests = [
    # https://github.com/authlib/joserfc/issues/94
    "test_ECDH_ES_with_EC_key"
    "test_import_p512_key"
    "test_ec_incorrect_curve"
    "test_ES512"
  ];

  optional-dependencies = {
    drafts = [ pycryptodome ];
  };

  pyproject = true;
  pythonImportsCheck = [ "joserfc" ];

  meta = {
    description = "Implementations of JOSE RFCs in Python";
    homepage = "https://github.com/authlib/joserfc";
    changelog = "https://github.com/authlib/joserfc/blob/${src.tag}/docs/changelog.rst";
    license = lib.licenses.bsd3;
    maintainers = [ ];
  };
}

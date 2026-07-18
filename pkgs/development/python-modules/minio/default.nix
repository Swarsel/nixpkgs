{
  lib,
  fetchFromGitHub,
  # dependencies
  argon2-cffi,
  buildPythonPackage,
  certifi,
  # test
  faker,
  mock,
  pycryptodome,
  pytestCheckHook,
  # build-system
  setuptools,
  typing-extensions,
  urllib3,
}:

buildPythonPackage rec {
  pname = "minio";
  version = "7.2.20";

  src = fetchFromGitHub {
    owner = "minio";
    repo = "minio-py";
    tag = version;
    hash = "sha256-k7bMXEwRNqx5a6qz4+Yxs/zMANReHFKU2Ks/GSD4JKo=";
  };

  postPatch = ''
    substituteInPlace tests/unit/crypto_test.py \
      --replace-fail "assertEquals" "assertEqual"
  '';

  nativeCheckInputs = [
    faker
    mock
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    argon2-cffi
    certifi
    urllib3
    pycryptodome
    typing-extensions
  ];

  disabledTestPaths = [
    # example credentials aren't present
    "tests/unit/credentials_test.py"
  ];

  pyproject = true;
  pythonImportsCheck = [ "minio" ];

  meta = {
    description = "Simple APIs to access any Amazon S3 compatible object storage server";
    homepage = "https://github.com/minio/minio-py";
    changelog = "https://github.com/minio/minio-py/releases/tag/${src.tag}";
    license = lib.licenses.asl20;
  };
}

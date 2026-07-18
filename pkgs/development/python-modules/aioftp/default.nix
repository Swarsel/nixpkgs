{
  lib,
  stdenv,
  async-timeout,
  buildPythonPackage,
  fetchPypi,
  pytest-asyncio,
  pytest-cov-stub,
  pytest-mock,
  pytestCheckHook,
  setuptools,
  siosocks,
  trustme,
}:

buildPythonPackage rec {
  pname = "aioftp";
  version = "0.27.2";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-fASMMiAIF5bFmDKm/Z/Y+tl+POwSpQvjq8zy3LvrJho=";
  };

  nativeCheckInputs = [
    async-timeout
    pytest-asyncio
    pytest-cov-stub
    pytest-mock
    pytestCheckHook
    trustme
  ]
  ++ lib.concatAttrValues optional-dependencies;

  build-system = [ setuptools ];

  disabledTests = lib.optionals stdenv.hostPlatform.isDarwin [
    # uses 127.0.0.2, which macos doesn't like
    "test_pasv_connection_pasv_forced_response_address"
  ];

  optional-dependencies = {
    socks = [ siosocks ];
  };

  pyproject = true;
  pythonImportsCheck = [ "aioftp" ];

  meta = {
    description = "Python FTP client/server for asyncio";
    homepage = "https://aioftp.readthedocs.io/";
    changelog = "https://github.com/aio-libs/aioftp/blob/${version}/history.rst";
    license = lib.licenses.asl20;
    maintainers = [ ];
  };
}

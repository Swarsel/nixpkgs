{
  lib,
  buildPythonPackage,
  certifi,
  cryptography,
  fetchPypi,
  openssl,
  pylsqpack,
  pyopenssl,
  pytestCheckHook,
  service-identity,
  setuptools,
}:

buildPythonPackage rec {
  pname = "aioquic";
  version = "1.3.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-KNBwshg+PnmvqdTnvVWJYNDVOuuYvAzwo1iyebp5fJI=";
  };

  buildInputs = [ openssl ];
  nativeCheckInputs = [ pytestCheckHook ];
  __darwinAllowLocalNetworking = true;
  build-system = [ setuptools ];

  dependencies = [
    certifi
    cryptography
    pylsqpack
    pyopenssl
    service-identity
  ];

  pyproject = true;
  pythonImportsCheck = [ "aioquic" ];

  meta = {
    description = "Implementation of QUIC and HTTP/3";
    homepage = "https://github.com/aiortc/aioquic";
    changelog = "https://github.com/aiortc/aioquic/blob/${version}/docs/changelog.rst";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ onny ];
  };
}

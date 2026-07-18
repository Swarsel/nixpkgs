{
  lib,
  buildPythonPackage,
  cryptography,
  fetchPypi,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "alibabacloud-darabonba-signature-util";
  version = "0.0.4";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-cdebKuZZV7z79pnO2JT9p4KzL5Y18WFmNVM+WpDV/rA=";
    pname = "alibabacloud_darabonba_signature_util";
  };

  # Module has no tests
  doCheck = false;
  __structuredAttrs = true;
  build-system = [ setuptools ];
  dependencies = [ cryptography ];
  pyproject = true;
  pythonImportsCheck = [ "alibabacloud_darabonba_signature_util" ];

  meta = {
    description = "Darabonba Signature Util Library for Alibaba Cloud Python SDK";
    homepage = "https://github.com/aliyun/darabonba-crypto-util";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
  };
})

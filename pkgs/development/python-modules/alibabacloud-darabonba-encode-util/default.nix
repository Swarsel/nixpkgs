{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "alibabacloud-darabonba-encode-util";
  version = "0.0.2";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-8cSE8nbWBFD6SbSymHGU50H8svf6rn8ofArmWryF/U0=";
    pname = "alibabacloud_darabonba_encode_util";
  };

  # Module has no tests
  doCheck = false;
  __structuredAttrs = true;
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "alibabacloud_darabonba_encode_util" ];

  meta = {
    description = "Darabonba Encode Util Library for Alibaba Cloud Python SDK";
    homepage = "https://github.com/aliyun/darabonba-crypto-util";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
  };
})

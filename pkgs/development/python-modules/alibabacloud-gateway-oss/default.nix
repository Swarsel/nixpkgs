{
  lib,
  alibabacloud-darabonba-array,
  alibabacloud-darabonba-encode-util,
  alibabacloud-darabonba-map,
  alibabacloud-darabonba-signature-util,
  alibabacloud-darabonba-string,
  alibabacloud-darabonba-time,
  alibabacloud-gateway-oss-util,
  alibabacloud-gateway-spi,
  alibabacloud-openapi-util,
  alibabacloud-oss-util,
  alibabacloud-tea-util,
  alibabacloud-tea-xml,
  buildPythonPackage,
  darabonba-core,
  fetchPypi,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "alibabacloud-gateway-oss";
  version = "0.0.27";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-sUBDgkDLzieRDe08J2iVdcAwHwrhGghKqii3ST3rYFI=";
    pname = "alibabacloud_gateway_oss";
  };

  # Module has only tests in the untagged upstream repo
  doCheck = false;
  __structuredAttrs = true;
  build-system = [ setuptools ];

  dependencies = [
    alibabacloud-gateway-spi
    alibabacloud-tea-util
    alibabacloud-oss-util
    alibabacloud-openapi-util
    alibabacloud-tea-xml
    alibabacloud-darabonba-string
    alibabacloud-darabonba-map
    alibabacloud-darabonba-array
    alibabacloud-darabonba-encode-util
    alibabacloud-darabonba-signature-util
    alibabacloud-darabonba-time
    alibabacloud-gateway-oss-util
    darabonba-core
  ];

  pyproject = true;
  pythonImportsCheck = [ "alibabacloud_gateway_oss" ];

  meta = {
    description = "Aliyun Gateway OSS Library for Python";
    homepage = "https://pypi.org/project/alibabacloud-gateway-oss/";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
  };
})

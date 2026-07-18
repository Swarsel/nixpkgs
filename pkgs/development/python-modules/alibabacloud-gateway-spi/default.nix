{
  lib,
  alibabacloud-credentials,
  buildPythonPackage,
  fetchPypi,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "alibabacloud-gateway-spi";
  version = "0.0.4";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-c9biDWW1Tu0m2JwZZA06dXLhjEXsraYn+Ab12+jtITA=";
    pname = "alibabacloud_gateway_spi";
  };

  # Module has only tests in the untagged upstream repo
  doCheck = false;
  __structuredAttrs = true;
  build-system = [ setuptools ];
  dependencies = [ alibabacloud-credentials ];
  pyproject = true;
  pythonImportsCheck = [ "alibabacloud_gateway_spi" ];

  meta = {
    description = "Aliyun Gateway SPI Library for Python";
    homepage = "https://pypi.org/project/alibabacloud-gateway-spi/";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
  };
})

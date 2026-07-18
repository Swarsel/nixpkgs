{
  lib,
  alibabacloud-credentials,
  alibabacloud-gateway-spi,
  alibabacloud-tea-util,
  buildPythonPackage,
  cryptography,
  darabonba-core,
  fetchPypi,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "alibabacloud-tea-openapi";
  version = "0.4.4";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-GwkXvAPNSUF9pklF6ScxcW1T4uuHB7I19U5Ft0cyIc4=";
    pname = "alibabacloud_tea_openapi";
  };

  # Module has only tests in the untagged upstream repo
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    alibabacloud-credentials
    alibabacloud-gateway-spi
    alibabacloud-tea-util
    cryptography
    darabonba-core
  ];

  pyproject = true;
  pythonImportsCheck = [ "Tea" ];
  pythonRelaxDeps = [ "cryptography" ];

  meta = {
    description = "Aliyun Tea OpenAPI Library for Python";
    homepage = "https://pypi.org/project/alibabacloud-tea-openapi/";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
  };
})

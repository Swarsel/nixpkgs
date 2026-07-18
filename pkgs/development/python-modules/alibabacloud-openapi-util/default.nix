{
  lib,
  alibabacloud-tea-util,
  buildPythonPackage,
  cryptography,
  fetchPypi,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "alibabacloud-openapi-util";
  version = "0.2.4";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-hwIrnct1k6YB96QMppgiesPMt3a1jLewa43H9RCZXDQ=";
    pname = "alibabacloud_openapi_util";
  };

  # Module has only tests in the untagged upstream repo
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    alibabacloud-tea-util
    cryptography
  ];

  pyproject = true;
  pythonImportsCheck = [ "alibabacloud_openapi_util" ];

  meta = {
    description = "Aliyun Tea OpenApi Library for Python";
    homepage = "https://pypi.org/project/alibabacloud-openapi-util/";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
  };
})

{
  lib,
  alibabacloud-endpoint-util,
  alibabacloud-openapi-util,
  alibabacloud-tea-openapi,
  alibabacloud-tea-util,
  buildPythonPackage,
  fetchPypi,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "alibabacloud-rds20140815";
  version = "15.9.1";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-nR1TzieZC84LqDnZWEVp5iTjCwwGU/MVbGSv2n0f4Eg=";
    pname = "alibabacloud_rds20140815";
  };

  # Module has no tests
  doCheck = false;
  __structuredAttrs = true;
  build-system = [ setuptools ];

  dependencies = [
    alibabacloud-endpoint-util
    alibabacloud-openapi-util
    alibabacloud-tea-openapi
    alibabacloud-tea-util
  ];

  pyproject = true;
  pythonImportsCheck = [ "alibabacloud_rds20140815" ];

  meta = {
    description = "Alibaba Cloud rds (20140815) SDK Library for Python";
    homepage = "https://pypi.org/project/alibabacloud-rds20140815/";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
  };
})

{
  lib,
  alibabacloud-tea-openapi,
  buildPythonPackage,
  darabonba-core,
  fetchPypi,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "alibabacloud-sas20181203";
  version = "9.3.3";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-Y1xDWiGmjuDkcgF6c031fe5xBO4tA8xUH9DIXBN2oRw=";
    pname = "alibabacloud_sas20181203";
  };

  # Module has no tests
  doCheck = false;
  __structuredAttrs = true;
  build-system = [ setuptools ];

  dependencies = [
    alibabacloud-tea-openapi
    darabonba-core
  ];

  pyproject = true;
  pythonImportsCheck = [ "alibabacloud_sas20181203" ];

  meta = {
    description = "Alibaba Cloud Threat Detection (20181203) SDK Library for Python";
    homepage = "https://pypi.org/project/alibabacloud-sas20181203/";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
  };
})

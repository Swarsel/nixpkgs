{
  lib,
  alibabacloud-tea-openapi,
  buildPythonPackage,
  darabonba-core,
  fetchPypi,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "alibabacloud-vpc20160428";
  version = "7.1.3";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-Hmrk0SWSH/r6Oa3LdpFjqIPko9ZdKt7Tl3ACxWnH9qM=";
    pname = "alibabacloud_vpc20160428";
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
  pythonImportsCheck = [ "alibabacloud_vpc20160428" ];

  meta = {
    description = "Alibaba Cloud Virtual Private Cloud (20160428) SDK Library for Python";
    homepage = "https://pypi.org/project/alibabacloud-vpc20160428/";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
  };
})

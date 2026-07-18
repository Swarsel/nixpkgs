{
  lib,
  alibabacloud-tea-openapi,
  buildPythonPackage,
  darabonba-core,
  fetchPypi,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "alibabacloud-sts20150401";
  version = "1.2.0";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-uXu8bL+1zycJ3bZBqJOZofbzAj2UwYM12pqTlWl538o=";
    pname = "alibabacloud_sts20150401";
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
  pythonImportsCheck = [ "alibabacloud_sts20150401" ];

  meta = {
    description = "Alibaba Cloud Sts (20150401) SDK Library for Python";
    homepage = "https://pypi.org/project/alibabacloud-sts20150401/";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
  };
})

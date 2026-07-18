{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "alibabacloud-darabonba-array";
  version = "0.1.0";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-f5p8YyUY/08M67DU6CWkjBLnzwuQFuolBU3XNzLhVao=";
    pname = "alibabacloud_darabonba_array";
  };

  # Module has no tests
  doCheck = false;
  __structuredAttrs = true;
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "alibabacloud_darabonba_array" ];

  meta = {
    description = "Alibaba Cloud Darabonba Array SDK Library for Python";
    homepage = "https://github.com/aliyun/darabonba-array";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
  };
})

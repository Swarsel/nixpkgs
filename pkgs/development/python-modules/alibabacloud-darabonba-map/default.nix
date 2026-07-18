{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "alibabacloud-darabonba-map";
  version = "0.0.1";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-rbFzhGWKGo9yQY8YONS2pf0lZr/TkqPvBtnbsKWVoj8=";
    pname = "alibabacloud_darabonba_map";
  };

  # Module has no tests
  doCheck = false;
  __structuredAttrs = true;
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "alibabacloud_darabonba_map" ];

  meta = {
    description = "Alibaba Cloud Darabonba Map SDK Library for Python";
    homepage = "https://github.com/aliyun/darabonba-map";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
  };
})

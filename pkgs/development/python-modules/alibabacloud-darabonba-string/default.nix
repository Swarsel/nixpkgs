{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "alibabacloud-darabonba-string";
  version = "0.0.4";

  src = fetchPypi {
    inherit (finalAttrs) version pname;
    hash = "sha256-7GYUwESNrcvF5GZIWDih+M/dkRE1vqc54gsUURJwxvc=";
  };

  # Module has no tests
  doCheck = false;
  __structuredAttrs = true;
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "alibabacloud_darabonba_string" ];

  meta = {
    description = "Alibaba Cloud Darabonba String Library for Python";
    homepage = "https://github.com/aliyun/darabonba-string";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
  };
})

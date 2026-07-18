{
  lib,
  buildPythonPackage,
  cryptography,
  fetchPypi,
  jmespath,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "aliyun-python-sdk-core";
  version = "2.16.0";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-ZRyq1ZfrOdT61s+FEz3/6Sg31TvfYtudjzfatlCLuPk=";
  };

  # All components are stored in a mono repo
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    cryptography
    jmespath
  ];

  pyproject = true;
  pythonImportsCheck = [ "aliyunsdkcore" ];
  pythonRelaxDeps = true;

  meta = {
    description = "Core module of Aliyun Python SDK";
    homepage = "https://github.com/aliyun/aliyun-openapi-python-sdk";
    changelog = "https://github.com/aliyun/aliyun-openapi-python-sdk/blob/master/aliyun-python-sdk-core/ChangeLog.txt";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
  };
})

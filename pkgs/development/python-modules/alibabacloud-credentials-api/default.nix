{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "alibabacloud-credentials-api";
  version = "1.0.1";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-jqBmimVY9pVrjSCy5WHRmoDqKcIs9WowBNQ0skqYGzY=";
    pname = "alibabacloud_credentials_api";
  };

  # Module has only tests in the untagged upstream repo
  doCheck = false;
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "alibabacloud_credentials_api" ];

  meta = {
    description = "Aliyun Credentials API Library for Python";
    homepage = "https://pypi.org/project/alibabacloud-credentials-api/";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
  };
})

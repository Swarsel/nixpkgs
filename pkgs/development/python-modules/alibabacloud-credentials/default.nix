{
  lib,
  aiofiles,
  alibabacloud-credentials-api,
  alibabacloud-tea,
  apscheduler,
  buildPythonPackage,
  fetchPypi,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "alibabacloud-credentials";
  version = "1.0.9";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-Ea1iBs4rrMW0ul8ses/sk9cERN/i4sBlyAF1EugoAZs=";
    pname = "alibabacloud_credentials";
  };

  # Module has only tests in the untagged upstream repo
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    aiofiles
    alibabacloud-credentials-api
    alibabacloud-tea
    apscheduler
  ];

  pyproject = true;
  pythonImportsCheck = [ "alibabacloud_credentials" ];
  pythonRelaxDeps = [ "aiofiles" ];

  meta = {
    description = "Aliyun Credentials Library for Python";
    homepage = "https://github.com/aliyun/credentials-python";
    changelog = "https://github.com/aliyun/credentials-python/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
  };
})

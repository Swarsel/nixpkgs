{
  lib,
  alibabacloud-tea,
  buildPythonPackage,
  fetchPypi,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "alibabacloud-oss-util";
  version = "0.0.6";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-0+zsNmMkNL1QmhE+jPMn3CPoMKyNndaUmSb04zTItdY=";
    pname = "alibabacloud_oss_util";
  };

  # Module has no tests
  doCheck = false;
  __structuredAttrs = true;
  build-system = [ setuptools ];
  dependencies = [ alibabacloud-tea ];
  pyproject = true;
  pythonImportsCheck = [ "alibabacloud_oss_util" ];

  meta = {
    description = "Alibaba Cloud Cloud OSS Util Library for Python";
    homepage = "https://pypi.org/project/alibabacloud-oss-util/";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
  };
})

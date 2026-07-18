{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "alibabacloud-gateway-oss-util";
  version = "0.0.13";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-RlWx2oGOieifxcs0UHhapFVZT5XYJAR3EXPJuJXtMDc=";
    pname = "alibabacloud_gateway_oss_util";
  };

  # Module has no tests
  doCheck = false;
  __structuredAttrs = true;
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "alibabacloud_gateway_oss_util" ];

  meta = {
    description = "Alibaba Cloud OSS Util Library for Python";
    homepage = "https://pypi.org/project/alibabacloud-gateway-oss-util/";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
  };
})

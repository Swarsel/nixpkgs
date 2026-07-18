{
  lib,
  alibabacloud-tea,
  buildPythonPackage,
  fetchPypi,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "alibabacloud-tea-util";
  version = "0.3.14";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-cI58n2RkGjyeDlZjZdLyNnX418Kj4pcdlALO7eBAjNs=";
    pname = "alibabacloud_tea_util";
  };

  # Module has only tests in the untagged upstream repo
  doCheck = false;
  __structuredAttrs = true;
  build-system = [ setuptools ];
  dependencies = [ alibabacloud-tea ];
  pyproject = true;
  pythonImportsCheck = [ "alibabacloud_tea_util" ];

  meta = {
    description = "Aliyun Tea Util Library for Python";
    homepage = "https://pypi.org/project/alibabacloud-tea-util/";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
  };
})

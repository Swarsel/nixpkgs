{
  lib,
  aiohttp,
  buildPythonPackage,
  fetchPypi,
  requests,
  setuptools,
}:

buildPythonPackage rec {
  pname = "alibabacloud-tea";
  version = "0.4.3";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-7IBT0KqNQ+vh3rYy1cVAQzmznsmhigcH1Xdlg4QYUEo=";
  };

  # Module has only tests in the untagged upstream repo
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    aiohttp
    requests
  ];

  pyproject = true;
  pythonImportsCheck = [ "Tea" ];

  meta = {
    description = "Aliyun Tea Library for Python";
    homepage = "https://pypi.org/project/alibabacloud-tea/";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
  };
}

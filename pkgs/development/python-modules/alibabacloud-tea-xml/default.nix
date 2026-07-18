{
  lib,
  alibabacloud-tea,
  buildPythonPackage,
  fetchPypi,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "alibabacloud-tea-xml";
  version = "0.0.3";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-l5y1H630Ped/QcafxpwSUpcokZ+ElyPrDNJOt7BIqQw=";
    pname = "alibabacloud_tea_xml";
  };

  # Module has only tests in the untagged upstream repo
  doCheck = false;
  build-system = [ setuptools ];
  dependencies = [ alibabacloud-tea ];
  pyproject = true;
  pythonImportsCheck = [ "alibabacloud_tea_xml" ];

  meta = {
    description = "Aliyun Tea XML Library for Python";
    homepage = "https://pypi.org/project/alibabacloud-tea-xml/";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
  };
})

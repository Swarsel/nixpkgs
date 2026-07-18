{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
}:

buildPythonPackage rec {
  pname = "alibabacloud-endpoint-util";
  version = "0.0.4";

  src = fetchPypi {
    inherit version;
    hash = "sha256-pZPrjd2BaNXcIhbNMxEbFE+RifzW6cog5I81inObv5A=";
    pname = "alibabacloud_endpoint_util";
  };

  # Module has only tests in the untagged upstream repo
  doCheck = false;
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "alibabacloud_endpoint_util" ];

  meta = {
    description = "Endpoint-util module of alibabaCloud Python SDK";
    homepage = "https://pypi.org/project/alibabacloud-endpoint-util/";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
  };
}

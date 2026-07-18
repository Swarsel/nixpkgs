{
  lib,
  botocore,
  buildPythonPackage,
  fetchPypi,
  poetry-core,
}:

buildPythonPackage rec {
  pname = "aws-error-utils";
  version = "2.7.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-BxB68qLCZwbNlSW3/77UPy0HtQ0n45+ekVbBGy6ZPJc=";
    pname = "aws_error_utils";
  };

  build-system = [
    poetry-core
  ];

  dependencies = [
    botocore
  ];

  pyproject = true;

  pythonImportsCheck = [
    "aws_error_utils"
  ];

  meta = {
    description = "Error-handling functions for boto3/botocore";
    homepage = "https://pypi.org/project/aws-error-utils/";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ cterence ];
  };
}

{
  lib,
  aws-error-utils,
  boto3,
  buildPythonPackage,
  fetchPypi,
  poetry-core,
}:

buildPythonPackage rec {
  pname = "aws-sso-lib";
  version = "1.14.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-sCA6ZMy2a6ePme89DrZpr/57wyP2q5yqyX81whoDzqU=";
    pname = "aws_sso_lib";
  };

  build-system = [
    poetry-core
  ];

  dependencies = [
    aws-error-utils
    boto3
  ];

  pyproject = true;

  pythonImportsCheck = [
    "aws_sso_lib"
  ];

  meta = {
    description = "Library to make AWS SSO easier";
    homepage = "https://pypi.org/project/aws-sso-lib/";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ cterence ];
  };
}

{
  lib,
  boto3,
  buildPythonPackage,
  fetchPypi,
  mock,
  pytestCheckHook,
  pyyaml,
  six,
}:

buildPythonPackage rec {
  pname = "serverlessrepo";
  version = "0.1.10";

  src = fetchPypi {
    inherit pname version;
    sha256 = "671f48038123f121437b717ed51f253a55775590f00fbab6fbc6a01f8d05c017";
  };

  postPatch = ''
    substituteInPlace setup.py \
      --replace "pyyaml~=5.1" "pyyaml" \
      --replace "boto3~=1.9, >=1.9.56" "boto3"
  '';

  propagatedBuildInputs = [
    six
    boto3
    pyyaml
  ];

  nativeCheckInputs = [
    pytestCheckHook
    mock
  ];

  enabledTestPaths = [ "tests/unit" ];
  format = "setuptools";
  pythonImportsCheck = [ "serverlessrepo" ];

  meta = {
    description = "Helpers for working with the AWS Serverless Application Repository";

    longDescription = ''
      A Python library with convenience helpers for working with the
      AWS Serverless Application Repository.
    '';

    homepage = "https://github.com/awslabs/aws-serverlessrepo-python";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ dhkl ];
  };
}

{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonPackage rec {
  pname = "infisicalsdk";
  version = "1.0.16";

  src = fetchFromGitHub {
    owner = "Infisical";
    repo = "python-sdk-official";
    tag = "v${version}";
    hash = "sha256-2bfT99ynl14CSbqIOG2SMQb3oW+uAWD+iJifdMQG8CE=";
  };

  doCheck = false;
  build-system = [ python3Packages.setuptools ];

  dependencies = with python3Packages; [
    python-dateutil
    aenum
    requests
    boto3
    botocore
  ];

  pyproject = true;
  pythonImportsCheck = [ "infisical_sdk" ];

  meta = {
    description = "Infisical Python SDK";
    homepage = "https://github.com/Infisical/python-sdk-official";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ artur-sannikov ];
  };
}

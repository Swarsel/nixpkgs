{
  lib,
  fetchFromGitHub,
  boto3,
  botocore,
  buildPythonPackage,
  click,
  configparser,
  fido2,
  lxml,
  poetry-core,
  pyopenssl,
  pytestCheckHook,
  requests,
  requests-kerberos,
  toml,
}:

buildPythonPackage rec {
  pname = "aws-adfs";
  version = "2.12.1";

  src = fetchFromGitHub {
    owner = "venth";
    repo = "aws-adfs";
    tag = "v${version}";
    hash = "sha256-U1ptI/VynHArJ1SwX4LanHB0f4U38YZO9XDCXcLBu+s=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    toml
  ];

  preCheck = ''
    export HOME=$(mktemp -d);
  '';

  build-system = [
    poetry-core
  ];

  dependencies = [
    boto3
    botocore
    click
    configparser
    fido2
    lxml
    pyopenssl
    requests
    requests-kerberos
  ];

  pyproject = true;
  pythonImportsCheck = [ "aws_adfs" ];

  pythonRelaxDeps = [
    "configparser"
    "fido2"
    "lxml"
    "requests-kerberos"
  ];

  meta = {
    description = "Command line tool to ease AWS CLI authentication against ADFS";
    homepage = "https://github.com/venth/aws-adfs";
    changelog = "https://github.com/venth/aws-adfs/releases/tag/${src.tag}";
    license = lib.licenses.psfl;
    mainProgram = "aws-adfs";
  };
}

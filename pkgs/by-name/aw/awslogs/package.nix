{
  lib,
  fetchFromGitHub,
  python3,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "awslogs";
  version = "0.15.0";

  src = fetchFromGitHub {
    owner = "jorgebastida";
    repo = "awslogs";
    tag = finalAttrs.version;
    sha256 = "sha256-o6xZqwlqAy01P+TZ0rB5rpEddWNUBzzHp7/cycpcwes=";
  };

  postPatch = ''
    substituteInPlace setup.py \
      --replace "boto3>=1.34.75" "boto3>=1.34.58"
  '';

  propagatedBuildInputs = with python3.pkgs; [
    boto3
    termcolor
    python-dateutil
    docutils
    setuptools
    jmespath
  ];

  nativeCheckInputs = with python3.pkgs; [
    pytestCheckHook
  ];

  pyproject = true;

  pythonImportsCheck = [
    "awslogs"
  ];

  meta = {
    description = "AWS CloudWatch logs for Humans";
    homepage = "https://github.com/jorgebastida/awslogs";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ dbrock ];
    mainProgram = "awslogs";
  };
})

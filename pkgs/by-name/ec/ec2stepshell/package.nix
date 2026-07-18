{
  lib,
  fetchFromGitHub,
  python3,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "ec2stepshell";
  version = "0-unstable-2023-04-07";

  src = fetchFromGitHub {
    owner = "saw-your-packet";
    repo = "EC2StepShell";
    rev = "ab1298fa7f2650de711e86e870a693dcce0e1935";
    hash = "sha256-zy33CgGwa2pBYouqaJ1LM6uRIh3Q1uxi2zNXpDNPsuQ=";
  };

  postPatch = ''
    # https://github.com/saw-your-packet/EC2StepShell/pull/1
    substituteInPlace pyproject.toml \
      --replace "realpython" "ec2stepshell"
  '';

  nativeBuildInputs = with python3.pkgs; [
    setuptools
  ];

  propagatedBuildInputs = with python3.pkgs; [
    boto3
    colorama
    pyfiglet
    termcolor
  ];

  pyproject = true;

  pythonImportsCheck = [
    "ec2stepshell"
  ];

  meta = {
    description = "AWS post-exploitation tool";
    homepage = "https://github.com/saw-your-packet/EC2StepShell";
    changelog = "https://github.com/saw-your-packet/EC2StepShell/blob/${finalAttrs.version}/CHANGELOG.txt";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "ec2stepshell";
  };
})

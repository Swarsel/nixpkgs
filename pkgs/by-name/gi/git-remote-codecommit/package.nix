{
  lib,
  fetchFromGitHub,
  awscli,
  python3Packages,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "git-remote-codecommit";
  version = "1.17";

  src = fetchFromGitHub {
    owner = "aws";
    repo = "git-remote-codecommit";
    tag = finalAttrs.version;
    hash = "sha256-8heI0Oyfhuvshedw+Eqmwd+e9cOHdDt4O588dplqv/k=";
  };

  nativeCheckInputs = [
    awscli
  ]
  ++ (with python3Packages; [
    pytestCheckHook
    mock
    flake8
    tox
  ]);

  build-system = with python3Packages; [ setuptools ];
  # The check dependency awscli has some overrides
  # which yield a different botocore.
  # This results in a duplicate version during installation
  # of the wheel, even though it does not matter
  # because it is only a test dependency.
  catchConflicts = false;
  dependencies = with python3Packages; [ botocore ];
  disabled = !python3Packages.isPy3k;
  pyproject = true;

  meta = {
    description = "Git remote prefix to simplify pushing to and pulling from CodeCommit";
    homepage = "https://github.com/awslabs/git-remote-codecommit";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.zaninime ];
    mainProgram = "git-remote-codecommit";
  };
})

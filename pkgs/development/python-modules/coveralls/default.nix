{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  coverage,
  docopt,
  git,
  # checks
  mock,
  # build-system
  poetry-core,
  pytestCheckHook,
  requests,
  responses,
  sh,
}:

buildPythonPackage rec {
  pname = "coveralls";
  version = "4.0.2";

  src = fetchFromGitHub {
    owner = "TheKevJames";
    repo = "coveralls-python";
    tag = version;
    hash = "sha256-c7YV1SAbxmqfVI/wGtfdr+S4T7G2q7tf0FhuyCJaPDg=";
  };

  nativeCheckInputs = [
    mock
    sh
    pytestCheckHook
    responses
    git
  ];

  preCheck = ''
    export PATH=${coverage}/bin:$PATH
  '';

  build-system = [ poetry-core ];

  dependencies = [
    coverage
    docopt
    requests
  ];

  disabledTests = [
    # requires .git in checkout
    "test_git"
    # try to run unwrapped python
    "test_5"
    "test_7"
    "test_11"
  ];

  pyproject = true;

  meta = {
    description = "Show coverage stats online via coveralls.io";
    homepage = "https://github.com/coveralls-clients/coveralls-python";
    license = lib.licenses.mit;
    mainProgram = "coveralls";
  };
}

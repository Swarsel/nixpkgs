{
  lib,
  fetchFromGitHub,
  git,
  mu-repo,
  python3Packages,
  testers,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "mu-repo";
  version = "1.9.0";

  src = fetchFromGitHub {
    owner = "fabioz";
    repo = "mu-repo";
    tag = "mu_repo_${lib.replaceStrings [ "." ] [ "_" ] finalAttrs.version}";
    hash = "sha256-aSRf0B/skoZLsn4dykWOFKVNtHYCsD9RtZ1frHDrcJU=";
  };

  nativeCheckInputs = [
    python3Packages.pytestCheckHook
    git
  ];

  dependencies = [ git ];
  disabledTests = [ "test_action_diff" ];
  format = "setuptools";

  passthru.tests.version = testers.testVersion {
    package = mu-repo;
  };

  meta = {
    description = "Tool to help in dealing with multiple git repositories";
    homepage = "http://fabioz.github.io/mu-repo/";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ sikmir ];
    platforms = lib.platforms.unix;
    mainProgram = "mu";
  };
})

{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # dependencies
  click,
  joblib,
  # tests
  pytestCheckHook,
  regex,
  # build-system
  setuptools,
  tqdm,
}:

buildPythonPackage (finalAttrs: {
  pname = "sacremoses";
  version = "0.1.1";

  src = fetchFromGitHub {
    owner = "hplt-project";
    repo = "sacremoses";
    tag = finalAttrs.version;
    sha256 = "sha256-ked6/8oaGJwVW1jvpjrWtJYfr0GKUHdJyaEuzid/S3M=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];

  dependencies = [
    click
    joblib
    regex
    tqdm
  ];

  # ignore tests which call to remote host
  disabledTestPaths = [
    "sacremoses/test/test_truecaser.py::TestTruecaser"
  ];

  pyproject = true;

  meta = {
    description = "Python port of Moses tokenizer, truecaser and normalizer";
    homepage = "https://github.com/alvations/sacremoses";
    license = lib.licenses.lgpl21Plus;
    maintainers = with lib.maintainers; [ pashashocky ];
    platforms = lib.platforms.unix;
    mainProgram = "sacremoses";
  };
})

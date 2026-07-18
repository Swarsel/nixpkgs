{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hatch-vcs,
  hatchling,
  paramiko,
  psutil,
  pytest-cov-stub,
  pytest-mock,
  pytest-timeout,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "plumbum";
  version = "1.10.0";

  src = fetchFromGitHub {
    owner = "tomerfiliba";
    repo = "plumbum";
    tag = "v${version}";
    hash = "sha256-ca9avbBJnMecuKljIrx3mYIGA50QXmhC/LP3hM9Uvcs=";
  };

  nativeCheckInputs = [
    psutil
    pytest-cov-stub
    pytest-mock
    pytest-timeout
    pytestCheckHook
  ]
  ++ lib.concatAttrValues optional-dependencies;

  preCheck = ''
    export HOME=$TMP
  '';

  build-system = [
    hatchling
    hatch-vcs
  ];

  disabledTestPaths = [
    # incompatible with pytest7
    # https://github.com/tomerfiliba/plumbum/issues/594
    "tests/test_remote.py"
  ];

  disabledTests = [
    # broken in nix env
    "test_change_env"
    "test_dictlike"
    "test_local"
    # incompatible with pytest 7
    "test_incorrect_login"
  ];

  optional-dependencies = {
    ssh = [ paramiko ];
  };

  pyproject = true;

  meta = {
    description = "Module Shell Combinators";
    homepage = "https://github.com/tomerfiliba/plumbum";
    changelog = "https://github.com/tomerfiliba/plumbum/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}

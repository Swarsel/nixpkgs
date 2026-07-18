{
  lib,
  fetchFromGitHub,
  boto3,
  buildPythonPackage,
  python,
  requests,
  setuptools,
}:

buildPythonPackage rec {
  pname = "metaflow";
  version = "2.19.16";

  src = fetchFromGitHub {
    owner = "Netflix";
    repo = "metaflow";
    tag = version;
    hash = "sha256-A3r93vmWwpbdVXsaiY4Oo+LRjlkXCT8wpOTlNgQNxL0=";
  };

  checkPhase = ''
    runHook preCheck

    export HOME="$TMPDIR"
    export USER="metaflow-test-user"

    pushd test/core
    ${python.interpreter} run_tests.py --num-parallel $NIX_BUILD_CORES \
      --tests FlowOptionsTest,BasicLogTest
    popd

    runHook postCheck
  '';

  build-system = [
    setuptools
  ];

  dependencies = [
    boto3
    requests
  ];

  pyproject = true;
  pythonImportsCheck = [ "metaflow" ];

  meta = {
    description = "Open Source AI/ML Platform";
    homepage = "https://metaflow.org/";
    changelog = "https://github.com/Netflix/metaflow/releases/tag/${src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ kr7x ];
  };
}

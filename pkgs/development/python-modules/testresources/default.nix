{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  fixtures,
  pbr,
  pytestCheckHook,
  setuptools,
  testtools,
}:

buildPythonPackage rec {
  pname = "testresources";
  version = "2.0.2";

  src = fetchFromGitHub {
    owner = "testing-cabal";
    repo = "testresources";
    tag = version;
    hash = "sha256-cdZObOgBOUxYg4IGUUMb6arlpb6NTU7w+EW700LKH4Y=";
  };

  env.PBR_VERSION = version;

  nativeCheckInputs = [
    fixtures
    testtools
    pytestCheckHook
  ];

  build-system = [
    setuptools
    pbr
  ];

  dependencies = [
    pbr
  ];

  disabledTestPaths = [
    # imports fixtures.test.helpers, but fixtures does not install tests anymore
    # https://github.com/testing-cabal/fixtures/commit/349afbb1ec7dde2e472b4563025660a35e595153
    "testresources/tests/test_test_resource.py"
  ];

  pyproject = true;

  meta = {
    description = "Pyunit extension for managing expensive test resources";
    homepage = "https://launchpad.net/testresources";

    license = with lib.licenses; [
      asl20 # or
      bsd3
    ];

    maintainers = with lib.maintainers; [ nickcao ];
  };
}

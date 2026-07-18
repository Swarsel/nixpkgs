{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  hatchling,
  plumbum,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "rpyc";
  version = "6.0.2";

  src = fetchFromGitHub {
    owner = "tomerfiliba";
    repo = "rpyc";
    tag = version;
    hash = "sha256-KLAOt0FStHV0senU/I4chxgn3PPM59CGhjTr/5U0sa8=";
  };

  doCheck = !stdenv.hostPlatform.isDarwin;
  nativeCheckInputs = [ pytestCheckHook ];

  preCheck = ''
    export PYTHONPATH=$(pwd)/tests:$PYTHONPATH
  '';

  build-system = [ hatchling ];
  dependencies = [ plumbum ];

  disabledTestPaths = [
    # Internal import issue
    "tests/test_attributes.py"
    "tests/test_service_pickle.py"
    "tests/test_affinity.py"
    "tests/test_magic.py"
  ];

  disabledTests = [
    # Disable tests that requires network access
    "test_api"
    "test_close_timeout"
    "test_deploy"
    "test_listing"
    "test_pruning"
    "test_rpyc"
    "test_instancecheck_across_connections"
    # Internal import error
    "test_modules"
    # Test is outdated
    # ssl.SSLError: [SSL: NO_CIPHERS_AVAILABLE] no ciphers available (_ssl.c:997)
    "test_ssl_conenction"
  ];

  pyproject = true;
  pythonImportsCheck = [ "rpyc" ];

  meta = {
    description = "Remote Python Call (RPyC), a transparent and symmetric RPC library";
    homepage = "https://rpyc.readthedocs.org";
    changelog = "https://github.com/tomerfiliba-org/rpyc/blob/${version}/CHANGELOG.rst";
    license = with lib.licenses; [ mit ];
    maintainers = with lib.maintainers; [ fab ];
  };
}

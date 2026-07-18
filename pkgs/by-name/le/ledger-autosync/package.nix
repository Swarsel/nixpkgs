{
  lib,
  stdenv,
  fetchFromGitHub,
  hledger,
  ledger,
  python3Packages,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "ledger-autosync";
  version = "1.2.0";

  src = fetchFromGitHub {
    owner = "egh";
    repo = "ledger-autosync";
    tag = "v${finalAttrs.version}";
    hash = "sha256-bbFjDdxYr85OPjdvY3JYtCe/8Epwi+8JN60PKVKbqe0=";
  };

  nativeCheckInputs = [
    hledger
    ledger
    python3Packages.ledger
    python3Packages.pytestCheckHook
  ];

  build-system = with python3Packages; [ poetry-core ];

  dependencies = with python3Packages; [
    ofxclient
    ofxparse
  ];

  disabledTestPaths = lib.optionals stdenv.hostPlatform.isDarwin [
    # keyring.errors.KeyringError: Can't get password from keychain: (-50, 'Unknown Error')
    # keyring.backends.macOS.api.Error: (-50, 'Unknown Error')
    "tests/test_cli.py"
    "tests/test_weird_ofx.py"
  ];

  pyproject = true;

  meta = {
    description = "OFX/CSV autosync for ledger and hledger";
    homepage = "https://github.com/egh/ledger-autosync";
    changelog = "https://github.com/egh/ledger-autosync/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ eamsden ];
  };
})

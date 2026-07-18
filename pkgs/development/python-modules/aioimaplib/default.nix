{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  imaplib2,
  mock,
  poetry-core,
  pyopenssl,
  pytest-asyncio_0,
  pytestCheckHook,
  pytz,
}:

buildPythonPackage rec {
  pname = "aioimaplib";
  version = "2.0.1";

  src = fetchFromGitHub {
    owner = "iroco-co";
    repo = "aioimaplib";
    tag = version;
    hash = "sha256-njzSpKPis033eLoRKXL538ljyMOB43chslio1wodrKU=";
  };

  patches = [
    # https://github.com/iroco-co/aioimaplib/issues/125
    ./event-loop.patch
  ];

  postPatch = ''
    sed -i "/crypto.X509Extension/,+1d" tests/ssl_cert.py
  '';

  nativeCheckInputs = [
    imaplib2
    mock
    pyopenssl
    pytest-asyncio_0
    pytestCheckHook
    pytz
  ];

  __darwinAllowLocalNetworking = true;
  build-system = [ poetry-core ];

  disabledTests = [
    # TimeoutError
    "test_idle_start__exits_queue_get_without_timeout_error"
    "test_client_can_connect_to_server_over_ssl"
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    # Comparison to magic strings
    "test_idle_loop"
  ];

  pyproject = true;
  pythonImportsCheck = [ "aioimaplib" ];

  meta = {
    description = "Python asyncio IMAP4rev1 client library";
    homepage = "https://github.com/iroco-co/aioimaplib";
    changelog = "https://github.com/iroco-co/aioimaplib/blob/${src.tag}/CHANGES.rst";
    license = lib.licenses.gpl3Plus;
    maintainers = [ lib.maintainers.dotlambda ];
  };
}

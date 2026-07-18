{
  lib,
  fetchFromGitHub,
  aiohttp,
  bcrypt,
  buildPythonPackage,
  pyopenssl,
  pyotp,
  pytest-cov-stub,
  pytestCheckHook,
  python-gnupg,
  requests,
  setuptools,
}:

buildPythonPackage rec {
  pname = "proton-core";
  version = "0.7.0";

  src = fetchFromGitHub {
    owner = "ProtonVPN";
    repo = "python-proton-core";
    tag = "v${version}";
    hash = "sha256-ZT/LkppzeEDGs9aOCx561fA1EgAShPCnMs8c05mgF0k=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pytest-cov-stub
    pyotp
  ];

  build-system = [ setuptools ];

  dependencies = [
    bcrypt
    aiohttp
    pyopenssl
    python-gnupg
    requests
  ];

  disabledTestPaths = [
    # Single test, requires internet connection
    "tests/test_alternativerouting.py"
  ];

  disabledTests = [
    # Invalid modulus
    "test_modulus_verification"
    # Permission denied: '/run'
    "test_broken_data"
    "test_broken_index"
    "test_sessions"
    # No working transports found
    "test_auto_works_on_prod"
    "test_ping"
    "test_raw_ping"
    "test_successful"
    "test_without_pinning"
    # Failed assertions
    "test_bad_pinning_fingerprint_changed"
    "test_bad_pinning_url_changed"
    # Bcrypt 72-byte limit exceeded
    # https://github.com/ProtonVPN/python-proton-core/pull/10
    "test_compute_v"
    "test_generate_v"
    "test_srp"
  ];

  pyproject = true;
  pythonImportsCheck = [ "proton" ];

  meta = {
    description = "Core logic used by the other Proton components";
    homepage = "https://github.com/ProtonVPN/python-proton-core";
    license = lib.licenses.gpl3Only;
    maintainers = [ ];
  };
}

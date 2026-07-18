{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  gitUpdater,
  hypothesis,
  openssl,
  pytestCheckHook,
  setuptools,
  six,
}:

buildPythonPackage (finalAttrs: {
  pname = "ecdsa";
  version = "0.19.2";

  src = fetchFromGitHub {
    owner = "tlsfuzzer";
    repo = "python-ecdsa";
    tag = "python-ecdsa-${finalAttrs.version}";
    hash = "sha256-u+EwAF/EnF33l/gy5y8eoA7aVeI/0cq9DDL9UUwgPFw=";
  };

  patches = [
    # Python update caused one of the tests to fail. A patch that fixes this
    # has been submitted upstream, yet to be applied.
    # https://github.com/tlsfuzzer/python-ecdsa/pull/371
    ./pr-371-fix-test-2026-05-23.patch
  ];

  nativeCheckInputs = [
    hypothesis
    openssl # Only needed for tests
    pytestCheckHook
  ];

  build-system = [ setuptools ];
  dependencies = [ six ];
  pyproject = true;
  pythonImportsCheck = [ "ecdsa" ];

  passthru.updateScript = gitUpdater {
    rev-prefix = "python-ecdsa-";
  };

  meta = {
    description = "ECDSA cryptographic signature library";
    homepage = "https://github.com/warner/python-ecdsa";
    changelog = "https://github.com/tlsfuzzer/python-ecdsa/blob/${finalAttrs.src.tag}/NEWS";
    license = lib.licenses.mit;

    knownVulnerabilities = [
      # "I don't want people to use this library in production environments.
      # It's a teaching tool, it's a testing tool, it's absolutely not an
      # production grade implementation."
      # https://github.com/tlsfuzzer/python-ecdsa/issues/330
      "CVE-2024-23342"
    ];
  };
})

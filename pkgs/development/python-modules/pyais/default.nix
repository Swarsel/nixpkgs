{
  lib,
  stdenv,
  fetchFromGitHub,
  attrs,
  bitarray,
  buildPythonPackage,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "pyais";
  version = "3.1.0";

  src = fetchFromGitHub {
    owner = "M0r13n";
    repo = "pyais";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Jc96CjFP/phTnwaP7OWOIxdpYf1iBk4n5mKXdWoMvws=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  __darwinAllowLocalNetworking = true;
  build-system = [ setuptools ];

  dependencies = [
    attrs
    bitarray
  ];

  disabledTestPaths = [
    # Tests the examples which have additional requirements
    "tests/test_examples.py"
  ];

  disabledTests = lib.optionals stdenv.hostPlatform.isDarwin [
    # OSError: [Errno 48] Address already in use
    "test_full_message_flow"
  ];

  pyproject = true;
  pythonImportsCheck = [ "pyais" ];

  meta = {
    description = "Module for decoding and encoding AIS messages (AIVDM/AIVDO)";
    homepage = "https://github.com/M0r13n/pyais";
    changelog = "https://github.com/M0r13n/pyais/blob/${finalAttrs.src.tag}/CHANGELOG.txt";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
})

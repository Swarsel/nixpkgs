{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "imap-tools";
  version = "1.13.0";

  src = fetchFromGitHub {
    owner = "ikvk";
    repo = "imap_tools";
    tag = "v${version}";
    hash = "sha256-1BcSF40yUbOvOVDsoqS4AXRU2GZ1a3f9p8Xz7crsfwc=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];

  disabledTests = [
    # tests require a network connection
    "test_action"
    "test_attributes"
    "test_connection"
    "test_folders"
    "test_idle"
    "test_live"
  ];

  pyproject = true;
  pythonImportsCheck = [ "imap_tools" ];

  meta = {
    description = "Work with email and mailbox by IMAP";
    homepage = "https://github.com/ikvk/imap_tools";
    changelog = "https://github.com/ikvk/imap_tools/blob/${src.tag}/docs/release_notes.rst";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}

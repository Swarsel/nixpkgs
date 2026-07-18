{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  dissect-cstruct,
  dissect-util,
  pytestCheckHook,
  setuptools,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "dissect-ntfs";
  version = "3.16";

  src = fetchFromGitHub {
    owner = "fox-it";
    repo = "dissect.ntfs";
    tag = version;
    hash = "sha256-5B27K6HPxSgdYLp0rJ1ld37xS3JXGqGlS/nlx4HBsVY=";
  };

  nativeCheckInputs = [ pytestCheckHook ];

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    dissect-cstruct
    dissect-util
  ];

  disabledTestPaths = [
    # Test is very time consuming
    "tests/test_index.py"
  ];

  disabledTests = [
    # Issue with archive
    "test_mft"
    "test_ntfs"
    "test_secure"
    "test_fragmented_mft"
  ];

  pyproject = true;
  pythonImportsCheck = [ "dissect.ntfs" ];

  meta = {
    description = "Dissect module implementing a parser for the NTFS file system";
    homepage = "https://github.com/fox-it/dissect.ntfs";
    changelog = "https://github.com/fox-it/dissect.ntfs/releases/tag/${src.tag}";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ fab ];
  };
}

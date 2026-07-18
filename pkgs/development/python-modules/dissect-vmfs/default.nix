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
  pname = "dissect-vmfs";
  version = "3.13";

  src = fetchFromGitHub {
    owner = "fox-it";
    repo = "dissect.vmfs";
    tag = version;
    hash = "sha256-4c3JVbQidGvXurWaO+/E0OehGgiY5shE5BiIBwMrCWM=";
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

  disabledTests = [
    # Archive not present
    "test_huge"
    "test_lvm_basic"
    "test_lvm_span"
    "test_sparse"
    "test_vmfs_basic"
    "test_vmfs_content"
    "test_vmfs_jbosf"
  ];

  pyproject = true;
  pythonImportsCheck = [ "dissect.vmfs" ];

  meta = {
    description = "Dissect module implementing a parser for the VMFS file system";
    homepage = "https://github.com/fox-it/dissect.vmfs";
    changelog = "https://github.com/fox-it/dissect.vmfs/releases/tag/${src.tag}";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ fab ];
  };
}

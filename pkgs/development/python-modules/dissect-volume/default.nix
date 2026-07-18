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

buildPythonPackage (finalAttrs: {
  pname = "dissect-volume";
  version = "3.18";

  src = fetchFromGitHub {
    owner = "fox-it";
    repo = "dissect.volume";
    tag = finalAttrs.version;
    hash = "sha256-2ivRkA4OLFntS2CtnXIr+/sLlcDVpmz6eINbejeH/3s=";
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
    # gzip.BadGzipFile: Not a gzipped file
    "test_apm"
    "test_bsd"
    "test_bsd64"
    "test_ddf_read"
    "test_dm_thin"
    "test_gpt_4k"
    "test_gpt_esxi_no_name_xff"
    "test_gpt_esxi"
    "test_gpt"
    "test_hybrid_gpt"
    "test_lvm_mirro"
    "test_lvm_thin"
    "test_lvm"
    "test_lvm"
    "test_mbr"
    "test_md_raid0_zones"
    "test_md_raid1_multiple_disks"
    "test_md_read"
    "test_vinum"
  ];

  pyproject = true;
  pythonImportsCheck = [ "dissect.volume" ];

  meta = {
    description = "Dissect module implementing various utility functions for the other Dissect modules";
    homepage = "https://github.com/fox-it/dissect.volume";
    changelog = "https://github.com/fox-it/dissect.volume/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ fab ];
  };
})

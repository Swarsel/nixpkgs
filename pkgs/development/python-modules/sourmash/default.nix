{
  lib,
  stdenv,
  bitstring,
  buildPythonPackage,
  cachetools,
  cffi,
  deprecation,
  fetchPypi,
  hypothesis,
  iconv,
  matplotlib,
  numpy,
  pytest-xdist,
  pytestCheckHook,
  pythonAtLeast,
  pyyaml,
  rocksdb_9_10,
  rustPlatform,
  scipy,
  screed,
}:
let
  rocksdb = rocksdb_9_10;
in
buildPythonPackage rec {
  pname = "sourmash";
  version = "4.9.4";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-KIidEQQeOYgxh1x9F6Nn4+WTewldAGdS5Fx/IwL0Ym0=";
  };

  nativeBuildInputs = with rustPlatform; [
    cargoSetupHook
    maturinBuildHook
    bindgenHook
  ];

  buildInputs = [ iconv ];

  propagatedBuildInputs = [
    bitstring
    cachetools
    cffi
    deprecation
    matplotlib
    numpy
    scipy
    screed
  ];

  env = {
    ROCKSDB_INCLUDE_DIR = "${rocksdb}/include";
    ROCKSDB_LIB_DIR = "${rocksdb}/lib";
  };

  nativeCheckInputs = [
    hypothesis
    pytest-xdist
    pytestCheckHook
    pyyaml
  ];

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit pname version src;
    hash = "sha256-/tVuR31T38/xx1+jglSGECAT1GmQEddQp9o6zAqlPyY=";
  };

  # TODO(luizirber): Working on fixing these upstream
  disabledTests = [
    "test_compare_no_such_file"
    "test_do_sourmash_index_multiscaled_rescale_fail"
    "test_metagenome_kreport_out_fail"
  ]
  ++ lib.optionals (pythonAtLeast "3.14") [
    # argparse subparser usage prefix changed in 3.14
    "test_cmd_3"
  ]
  ++ lib.optionals (stdenv.hostPlatform.isDarwin && stdenv.hostPlatform.isAarch64) [
    # rocksdb segfaults pytest workers
    "rocksdb"
    "disk_revindex"
    "create_dataset_picklist"
  ];

  pyproject = true;
  pythonImportsCheck = [ "sourmash" ];

  meta = {
    description = "Quickly search, compare, and analyze genomic and metagenomic data sets";
    homepage = "https://sourmash.bio";
    changelog = "https://github.com/sourmash-bio/sourmash/releases/tag/v${version}";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ luizirber ];
    mainProgram = "sourmash";
  };
}

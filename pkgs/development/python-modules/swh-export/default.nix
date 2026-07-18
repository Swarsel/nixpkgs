{
  lib,
  fetchFromGitLab,
  boto3,
  buildPythonPackage,
  click,
  luigi,
  pkgs,
  plyvel,
  pyorc,
  pytest-click,
  pytest-mock,
  pytestCheckHook,
  python,
  setuptools,
  setuptools-scm,
  swh-core,
  swh-journal,
  swh-model,
  swh-storage,
  tqdm,
  types-requests,
  tzdata,
}:

buildPythonPackage (finalAttrs: {
  pname = "swh-export";
  version = "1.11.7";

  src = fetchFromGitLab {
    owner = "devel";
    repo = "swh-export";
    tag = "v${finalAttrs.version}";
    hash = "sha256-aDIGbkyRMNoQOdlXwqfLyRqDfK6jNFMVFJv67OY1SCg=";
    domain = "gitlab.softwareheritage.org";
    group = "swh";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pytest-click
    pytest-mock
    pkgs.zstd
    pkgs.pv
  ];

  preCheck = ''
    # provide timezone data, works only on linux
    export TZDIR=${tzdata}/${python.sitePackages}/tzdata/zoneinfo
  '';

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    boto3
    click
    luigi
    tqdm
    pyorc
    plyvel
    types-requests
    swh-core
    swh-journal
    swh-model
    swh-storage
  ];

  disabledTests = [
    # I don't know how to fix the following error
    # E       fixture 'kafka_server' not found
    "test_parallel_journal_processor"
    "test_parallel_journal_processor_origin"
    "test_parallel_journal_processor_origin_visit_status"
    "test_parallel_journal_processor_offsets"
    "test_parallel_journal_processor_masked"
    "test_parallel_journal_processor_masked_origin"
    "test_parallel_journal_processor_masked_origin_visit_statuses"
  ];

  pyproject = true;
  pythonImportsCheck = [ "swh.export" ];

  meta = {
    description = "Software Heritage dataset tools";
    homepage = "https://gitlab.softwareheritage.org/swh/devel/swh-export";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ drupol ];
  };
})

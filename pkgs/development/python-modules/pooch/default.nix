{
  lib,
  buildPythonPackage,
  fetchPypi,
  packaging,
  paramiko,
  platformdirs,
  pytestCheckHook,
  requests,
  setuptools,
  setuptools-scm,
  tqdm,
  wheel,
  xxhash,
}:

buildPythonPackage rec {
  pname = "pooch";
  version = "1.8.2";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-dlYfDeaKAdpN9q846ZVcTJ0aXJDac/fkAnalco7IPRA=";
  };

  nativeBuildInputs = [
    setuptools
    setuptools-scm
    wheel
  ];

  propagatedBuildInputs = [
    packaging
    platformdirs
    requests
  ];

  nativeCheckInputs = [ pytestCheckHook ];

  preCheck = ''
    export HOME=$TMPDIR
  '';

  # tries to touch network
  disabledTests = [
    "check_availability"
    "decompress"
    "downloader"
    "extractprocessor_fails"
    "integration"
    "pooch_corrupted"
    "pooch_custom_url"
    "pooch_download"
    "pooch_logging_level"
    "pooch_update"
    "processor"
    "test_fetch"
    "test_load_registry_from_doi"
    "test_retrieve"
    "test_stream_download"
  ];

  pyproject = true;

  passthru = {
    optional-dependencies = {
      progress = [ tqdm ];
      sftp = [ paramiko ];
      xxhash = [ xxhash ];
    };
  };

  meta = {
    description = "Friend to fetch your data files";
    homepage = "https://github.com/fatiando/pooch";
    license = lib.licenses.bsd3;
    maintainers = [ ];
  };
}

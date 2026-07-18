{
  lib,
  fetchFromGitHub,
  azure-storage-blob,
  boto3,
  buildPythonPackage,
  google-auth,
  google-cloud-storage,
  python-dotenv,
  requests,
  responses,
  setuptools,
  setuptools-git-versioning,
  setuptools-scm,
  urllib3,
}:

buildPythonPackage rec {
  pname = "sapi-python-client";
  version = "0.9.5";

  src = fetchFromGitHub {
    owner = "keboola";
    repo = "sapi-python-client";
    tag = version;
    hash = "sha256-i+SI5F48C90Af04boedEk72obctHp9PJIv8m0ewpGR0=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail "urllib3<2.0.0" "urllib3"
  '';

  # Requires API token and an active Keboola bucket
  # ValueError: Root URL is required.
  doCheck = false;

  build-system = [
    setuptools
    setuptools-git-versioning
    setuptools-scm
  ];

  dependencies = [
    azure-storage-blob
    boto3
    python-dotenv
    requests
    responses
    urllib3
    google-auth
    google-cloud-storage
  ];

  pyproject = true;

  pythonImportsCheck = [
    "kbcstorage"
    "kbcstorage.buckets"
    "kbcstorage.client"
    "kbcstorage.tables"
  ];

  pythonRelaxDeps = [
    "google-cloud-storage"
    "google-auth"
  ];

  meta = {
    description = "Keboola Connection Storage API client";
    homepage = "https://github.com/keboola/sapi-python-client";
    changelog = "https://github.com/keboola/sapi-python-client/releases/tag/${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ mrmebelman ];
  };
}

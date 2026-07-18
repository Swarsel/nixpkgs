{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  fs,
  google-cloud-storage,
  google-crc32c,
  pytest-cov-stub,
  pytestCheckHook,
  requests,
  setuptools,
}:

buildPythonPackage rec {
  pname = "gcp-storage-emulator";
  version = "2024.08.03";

  src = fetchFromGitHub {
    owner = "oittaa";
    repo = "gcp-storage-emulator";
    tag = "v${version}";
    hash = "sha256-Lp9Wvod0wSE2+cnvLXguhagT30ax9TivyR8gC/kB7w0=";
  };

  nativeCheckInputs = [
    google-cloud-storage
    pytest-cov-stub
    pytestCheckHook
    requests
  ];

  build-system = [
    setuptools
  ];

  dependencies = [
    fs
    google-crc32c
  ];

  disabledTests = [
    "test_invalid_crc32c_hash" # AssertionError
  ];

  pyproject = true;

  pythonImportsCheck = [
    "gcp_storage_emulator"
  ];

  meta = {
    description = "Local emulator for Google Cloud Storage";
    homepage = "https://github.com/oittaa/gcp-storage-emulator";
    license = lib.licenses.bsd3;
    maintainers = [ ];
    mainProgram = "gcp-storage-emulator";
  };
}

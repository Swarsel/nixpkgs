{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  freezegun,
  pytestCheckHook,
  python-dateutil,
  setuptools,
  tokenize-rt,
}:

buildPythonPackage (finalAttrs: {
  pname = "time-machine";
  version = "3.2.0";

  src = fetchFromGitHub {
    owner = "adamchainz";
    repo = "time-machine";
    tag = finalAttrs.version;
    hash = "sha256-UWoKvNz0ojVZtkIUGT02zJitza+mkyToANQMsU64xL4=";
  };

  nativeCheckInputs = [
    freezegun
    pytestCheckHook
  ]
  ++ finalAttrs.passthru.optional-dependencies.cli;

  build-system = [ setuptools ];

  dependencies = [
    python-dateutil
  ];

  disabledTests = [
    # https://github.com/adamchainz/time-machine/issues/405
    "test_destination_string_naive"
    # Assertion Errors related to Africa/Addis_Ababa
    "test_destination_datetime_tzinfo_zoneinfo_nested"
    "test_destination_datetime_tzinfo_zoneinfo_no_orig_tz"
    "test_destination_datetime_tzinfo_zoneinfo"
    "test_move_to_datetime_with_tzinfo_zoneinfo"
  ];

  optional-dependencies.cli = [
    tokenize-rt
  ];

  pyproject = true;
  pythonImportsCheck = [ "time_machine" ];

  meta = {
    description = "Travel through time in your tests";
    homepage = "https://github.com/adamchainz/time-machine";
    changelog = "https://github.com/adamchainz/time-machine/blob/${finalAttrs.src.tag}/CHANGELOG.rst";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
})

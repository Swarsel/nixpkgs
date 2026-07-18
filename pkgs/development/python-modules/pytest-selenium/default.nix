{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hatch-vcs,
  hatchling,
  pytest,
  pytest-base-url,
  pytest-html,
  pytest-mock,
  pytest-variables,
  pytest-xdist,
  pytestCheckHook,
  requests,
  selenium,
  tenacity,
}:

buildPythonPackage rec {
  pname = "pytest-selenium";
  version = "4.1.0";

  src = fetchFromGitHub {
    owner = "pytest-dev";
    repo = "pytest-selenium";
    tag = version;
    hash = "sha256-fIyos73haqTAgp5WVvMwJswQAtXnsnUeXKjPweXLGRM=";
  };

  nativeCheckInputs = [
    pytest-mock
    pytest-xdist
    pytestCheckHook
  ];

  build-system = [
    hatch-vcs
    hatchling
  ];

  buildInput = [ pytest ];

  dependencies = [
    pytest-base-url
    pytest-html
    pytest-variables
    requests
    selenium
    tenacity
  ];

  disabledTests = [
    # Tests require additional setup and/or network features
    "test_driver_quit"
    "test_driver_retry_pass"
    "test_event_listening_webdriver"
    "test_invalid_credentials_env"
    "test_invalid_credentials_file"
    "test_invalid_host"
    "test_launch_case_insensitive"
    "test_launch"
    "test_options"
    "test_preferences_marker"
    "test_profile"
    "test_xdist"
  ];

  pyproject = true;
  pythonImportsCheck = [ "pytest_selenium" ];

  meta = {
    description = "Plugin for running Selenium with pytest";
    homepage = "https://github.com/pytest-dev/pytest-selenium";
    changelog = "https://github.com/pytest-dev/pytest-selenium/releases/tag/${version}";
    license = lib.licenses.mpl20;
    maintainers = with lib.maintainers; [ fab ];
  };
}

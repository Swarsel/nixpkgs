{
  lib,
  fetchFromGitHub,
  # tests
  bleak,
  buildPythonPackage,
  # dependencies
  habluetooth,
  # build-system
  poetry-core,
  pytest-cov-stub,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "home-assistant-bluetooth";
  version = "2.0.0";

  src = fetchFromGitHub {
    owner = "home-assistant-libs";
    repo = "home-assistant-bluetooth";
    tag = "v${version}";
    hash = "sha256-A29Jezj9kQ/v4irvpcpCiZlrNQBQwByrSJOx4HaXTdc=";
  };

  doCheck = false; # broken with habluetooth>=4.0

  nativeCheckInputs = [
    bleak
    pytest-cov-stub
    pytestCheckHook
  ];

  build-system = [
    poetry-core
    setuptools
  ];

  dependencies = [ habluetooth ];
  pyproject = true;
  pythonImportsCheck = [ "home_assistant_bluetooth" ];

  meta = {
    description = "Basic bluetooth models used by Home Assistant";
    homepage = "https://github.com/home-assistant-libs/home-assistant-bluetooth";
    changelog = "https://github.com/home-assistant-libs/home-assistant-bluetooth/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.asl20;
    teams = [ lib.teams.home-assistant ];
  };
}

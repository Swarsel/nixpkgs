{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # tests
  mock,
  # dependencies
  psutil,
  pyocd,
  pytestCheckHook,
  # build-system
  setuptools,
  six,
}:

buildPythonPackage rec {
  pname = "pylink-square";
  version = "1.6.0";

  src = fetchFromGitHub {
    owner = "square";
    repo = "pylink";
    tag = "v${version}";
    hash = "sha256-rkkdnpkl9UHcBDjp6lsFXR1zNn7tH1KeTQ7wV+yJ3m0=";
  };

  patches = [
    # ERROR: /build/source/setup.cfg:16: unexpected value continuation
    ./fix-setup-cfg-syntax.patch
  ];

  nativeCheckInputs = [
    mock
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    psutil
    six
  ];

  disabledTests = [
    # AttributeError: 'called_once_with' is not a valid assertion
    "test_cp15_register_write_success"
    "test_jlink_restarted"
    "test_set_log_file_success"
  ];

  pyproject = true;
  pythonImportsCheck = [ "pylink" ];

  passthru.tests = {
    inherit pyocd;
  };

  meta = {
    description = "Python interface for the SEGGER J-Link";
    homepage = "https://github.com/square/pylink";
    changelog = "https://github.com/square/pylink/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ dump_stack ];
  };
}

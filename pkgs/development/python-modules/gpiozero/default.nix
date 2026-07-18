{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # dependencies
  colorzero,
  pytest-cov-stub,
  # tests
  pytestCheckHook,
  # build-system
  setuptools,
  # docs
  sphinx-rtd-theme,
  sphinxHook,
}:

buildPythonPackage rec {
  pname = "gpiozero";
  version = "2.0.1";

  src = fetchFromGitHub {
    owner = "gpiozero";
    repo = "gpiozero";
    tag = "v${version}";
    hash = "sha256-ifdCFcMH6SrhKQK/TJJ5lJafSfAUzd6ZT5ANUzJGwxI=";
  };

  outputs = [
    "out"
    "doc"
  ];

  nativeBuildInputs = [
    setuptools
    sphinx-rtd-theme
    sphinxHook
  ];

  propagatedBuildInputs = [ colorzero ];

  nativeCheckInputs = [
    pytestCheckHook
    pytest-cov-stub
  ];

  disabledTests = [
    # https://github.com/gpiozero/gpiozero/issues/1087
    "test_spi_hardware_write"
  ];

  pyproject = true;

  pythonImportsCheck = [
    "gpiozero"
    "gpiozero.tools"
  ];

  meta = {
    description = "Simple interface to GPIO devices with Raspberry Pi";
    homepage = "https://github.com/gpiozero/gpiozero";
    changelog = "https://github.com/gpiozero/gpiozero/blob/v${version}/docs/changelog.rst";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ hexa ];
    platforms = lib.platforms.linux;
  };
}

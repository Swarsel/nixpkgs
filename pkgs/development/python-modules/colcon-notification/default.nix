{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  colcon,
  notify2,
  pytestCheckHook,
  scspell,
  setuptools,
  writableTmpDirAsHomeHook,
}:

buildPythonPackage rec {
  pname = "colcon-notification";
  version = "0.3.1";

  src = fetchFromGitHub {
    owner = "colcon";
    repo = "colcon-notification";
    tag = version;
    hash = "sha256-gKi5xl2ln+6CCwynUzh+WI87A4KHcrwbjkLJ6LmOoxk=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    scspell
    writableTmpDirAsHomeHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    colcon
    notify2
  ];

  disabledTestPaths = [
    # Linting/formatting tests are not relevant and would require extra dependencies
    "test/test_flake8.py"
  ];

  pyproject = true;

  pythonImportsCheck = [
    "colcon_notification"
  ];

  meta = {
    description = "Extension for colcon-core to provide status notifications";
    homepage = "https://github.com/colcon/colcon-notification";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ guelakais ];
  };
}

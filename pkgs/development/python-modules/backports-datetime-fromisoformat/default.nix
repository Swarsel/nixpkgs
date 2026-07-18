{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  # tests
  pytz,
  # build-system
  setuptools,
}:

buildPythonPackage rec {
  pname = "backports-datetime-fromisoformat";
  version = "2.0.3";

  src = fetchFromGitHub {
    owner = "movermeyer";
    repo = "backports.datetime_fromisoformat";
    tag = "v${version}";
    hash = "sha256-G1JMHa7r8KEOuIopXNBsPxu7yopFF1YlL5GUEmfuxqQ=";
  };

  nativeBuildInputs = [ setuptools ];

  nativeCheckInputs = [
    pytz
    pytestCheckHook
  ];

  disabledTestPaths = [
    # ModuleNotFoundError: No module named 'developmental_release'
    "release/test_developmental_release.py"
  ];

  pyproject = true;
  pythonImportsCheck = [ "backports.datetime_fromisoformat" ];

  meta = {
    description = "Backport of Python 3.11's datetime.fromisoformat";
    homepage = "https://github.com/movermeyer/backports.datetime_fromisoformat";
    changelog = "https://github.com/movermeyer/backports.datetime_fromisoformat/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}

{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "durationpy";
  version = "0.10";

  src = fetchFromGitHub {
    owner = "icholy";
    repo = "durationpy";
    tag = version;
    hash = "sha256-tJ3zOCROkwFWzTgIKx+0H7J1rNkwy5XJPh8Zec7jJ5g=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];
  enabledTestPaths = [ "test.py" ];
  pyproject = true;
  pythonImportsCheck = [ "durationpy" ];

  meta = {
    description = "Module for converting between datetime.timedelta and Go's time.Duration strings";
    homepage = "https://github.com/icholy/durationpy";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}

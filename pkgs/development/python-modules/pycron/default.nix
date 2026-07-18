{
  lib,
  fetchFromGitHub,
  arrow,
  buildPythonPackage,
  delorean,
  pendulum,
  poetry-core,
  pytestCheckHook,
  pytz,
  udatetime,
}:

buildPythonPackage rec {
  pname = "pycron";
  version = "3.2.0";

  src = fetchFromGitHub {
    owner = "kipe";
    repo = "pycron";
    tag = version;
    hash = "sha256-AuDqElqu/cbTASHQfWM85JHu8DvkwArZ2leMZSB+XVM=";
  };

  nativeCheckInputs = [
    arrow
    delorean
    pendulum
    pytestCheckHook
    pytz
    udatetime
  ];

  build-system = [ poetry-core ];

  disabledTestPaths = [
    # depens on nose
    "tests/test_has_been.py"
  ];

  pyproject = true;
  pythonImportsCheck = [ "pycron" ];

  meta = {
    description = "Simple cron-like parser for Python, which determines if current datetime matches conditions";
    homepage = "https://github.com/kipe/pycron";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}

{
  lib,
  buildPythonPackage,
  fetchPypi,
  pytestCheckHook,
  python-dateutil,
  pytz,
  setuptools,
  tzlocal,
}:

buildPythonPackage rec {
  pname = "croniter";
  version = "6.0.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-N8UEsxOVYRSpg+ziwrB3kLHxCU/p2BzJRzkhR0glVXc=";
  };

  nativeBuildInputs = [ setuptools ];

  propagatedBuildInputs = [
    python-dateutil
    pytz
  ];

  nativeCheckInputs = [
    pytestCheckHook
    tzlocal
  ];

  pyproject = true;
  pythonImportsCheck = [ "croniter" ];

  meta = {
    description = "Library to iterate over datetime object with cron like format";
    homepage = "https://github.com/kiorky/croniter";
    changelog = "https://github.com/kiorky/croniter/blob/${version}/CHANGELOG.rst";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}

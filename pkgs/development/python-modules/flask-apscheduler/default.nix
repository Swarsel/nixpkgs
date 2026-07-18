{
  lib,
  fetchFromGitHub,
  apscheduler,
  buildPythonPackage,
  flask,
  pytestCheckHook,
  python-dateutil,
  pytz,
  setuptools,
}:

buildPythonPackage rec {
  pname = "flask-apscheduler";
  version = "1.13.1";

  src = fetchFromGitHub {
    owner = "viniciuschiele";
    repo = "flask-apscheduler";
    tag = version;
    hash = "sha256-0gZueUuBBpKGWE6OCJiJL/EEIMqCVc3hgLKwIWFuSZI=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pytz
  ];

  __structuredAttrs = true;
  build-system = [ setuptools ];

  dependencies = [
    flask
    apscheduler
    python-dateutil
  ];

  pyproject = true;
  pythonImportsCheck = [ "flask_apscheduler" ];

  meta = {
    description = "APScheduler support for Flask";
    homepage = "https://github.com/viniciuschiele/flask-apscheduler";
    changelog = "https://github.com/viniciuschiele/flask-apscheduler/releases/tag/${version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ felbinger ];
  };
}

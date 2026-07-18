{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  isPyPy,
  pytestCheckHook,
  python-dateutil,
  pytz,
  setuptools,
  six,
}:

buildPythonPackage rec {
  pname = "vobject";
  version = "0.9.9";

  src = fetchFromGitHub {
    owner = "py-vobject";
    repo = "vobject";
    tag = "v${version}";
    hash = "sha256-OL0agVpV/kWph6KhpzDhfzayscs0OaJ2W9WIilXVaS0=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];

  dependencies = [
    python-dateutil
    pytz
    six
  ];

  disabled = isPyPy;
  enabledTestPaths = [ "tests.py" ];
  pyproject = true;
  pythonImportsCheck = [ "vobject" ];

  meta = {
    description = "Module for reading vCard and vCalendar files";
    homepage = "https://github.com/py-vobject/vobject";
    license = lib.licenses.asl20;
    maintainers = [ ];
  };
}

{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  dbus,
  hatchling,
  pygobject3,
  pytestCheckHook,
}:

buildPythonPackage {
  pname = "dasbus";
  version = "unstable-11-10-2022";

  src = fetchFromGitHub {
    owner = "rhinstaller";
    repo = "dasbus";
    rev = "64b6b4d9e37cd7e0cbf4a7bf75faa7cdbd01086d";
    hash = "sha256-TmhhDrfpP+nUErAd7dUb+RtGBRtWwn3bYOoIqa0VRoc=";
  };

  nativeCheckInputs = [
    dbus
    pytestCheckHook
  ];

  build-system = [ hatchling ];
  dependencies = [ pygobject3 ];

  disabledTestPaths = [
    # https://github.com/dasbus-project/dasbus/issues/128
    "tests/lib_dbus.py"
    "tests/test_dbus.py"
    "tests/test_unix.py"
  ];

  pyproject = true;

  meta = {
    description = "DBus library in Python3";
    homepage = "https://github.com/rhinstaller/dasbus";
    license = lib.licenses.lgpl21Only;
    maintainers = with lib.maintainers; [ moni ];
  };
}

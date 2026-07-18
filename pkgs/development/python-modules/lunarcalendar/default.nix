{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  ephem,
  pytestCheckHook,
  python-dateutil,
  pytz,
}:

buildPythonPackage {
  pname = "lunarcalendar";
  version = "0.0.9";

  src = fetchFromGitHub {
    owner = "wolfhong";
    repo = "LunarCalendar";
    rev = "885418ea1a2a90b7e0bbe758919af9987fb2863b";
    hash = "sha256-AhxCWWqCjlOroqs4pOSZTWoIQT8a1l/D2Rxuw1XUoU8=";
  };

  propagatedBuildInputs = [
    python-dateutil
    ephem
    pytz
  ];

  nativeCheckInputs = [ pytestCheckHook ];
  format = "setuptools";
  pythonImportsCheck = [ "lunarcalendar" ];

  meta = {
    description = "Lunar-Solar Converter, containing a number of lunar and solar festivals in China";
    homepage = "https://github.com/wolfhong/LunarCalendar";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ tomasajt ];
    mainProgram = "lunar-find";
  };
}

{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  numpy,
  pandas,
  pytest7CheckHook,
  pytz,
}:

buildPythonPackage rec {
  pname = "json-tricks";
  version = "3.17.3";

  src = fetchFromGitHub {
    owner = "mverleg";
    repo = "pyjson_tricks";
    tag = "v${version}";
    hash = "sha256-xddMc4PvVI+mqB3eeVqECZmdeSKAURsdbOnUAXahqM0=";
  };

  nativeCheckInputs = [
    numpy
    pandas
    pytz
    pytest7CheckHook
  ];

  format = "setuptools";
  pythonImportsCheck = [ "json_tricks" ];

  meta = {
    description = "Extra features for Python JSON handling";
    homepage = "https://github.com/mverleg/pyjson_tricks";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ bcdarwin ];
  };
}

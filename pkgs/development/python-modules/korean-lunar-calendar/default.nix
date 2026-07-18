{
  lib,
  buildPythonPackage,
  fetchPypi,
}:

buildPythonPackage rec {
  pname = "korean-lunar-calendar";
  version = "0.3.1";

  src = fetchPypi {
    inherit version;
    hash = "sha256-6yxIUSSgYQFpJr3qbYnv35uf2/FttViVts8eW+wXuFc=";
    pname = "korean_lunar_calendar";
  };

  format = "setuptools";
  # no real tests
  pythonImportsCheck = [ "korean_lunar_calendar" ];

  meta = {
    description = "Library to convert Korean lunar-calendar to Gregorian calendar";
    homepage = "https://github.com/usingsky/korean_lunar_calendar_py";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.ris ];
  };
}

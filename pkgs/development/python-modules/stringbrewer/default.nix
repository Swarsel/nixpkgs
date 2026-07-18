{
  lib,
  buildPythonPackage,
  fetchPypi,
  rstr,
  sre-yield,
}:

buildPythonPackage rec {
  pname = "stringbrewer";
  version = "0.0.1";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-wtETgi+Tk1ALJzzIM6Ic5zkDbALGL0cELg8X75uepkk=";
  };

  propagatedBuildInputs = [
    rstr
    sre-yield
  ];

  # Package has no tests
  doCheck = false;
  format = "setuptools";
  pythonImportsCheck = [ "stringbrewer" ];

  meta = {
    description = "Python library to generate random strings matching a pattern";
    homepage = "https://github.com/simoncozens/stringbrewer";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ danc86 ];
  };
}

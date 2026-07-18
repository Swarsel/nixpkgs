{
  lib,
  buildPythonPackage,
  easyprocess,
  entrypoint2,
  fetchPypi,
  isPy3k,
  jeepney,
  mss,
  pillow,
}:

buildPythonPackage rec {
  pname = "pyscreenshot";
  version = "3.1";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-jA6T8K72amv+Vahqv87WvTlq5LT2zB428EoorSYlWU0=";
  };

  propagatedBuildInputs = [
    easyprocess
    entrypoint2
    pillow
  ]
  ++ lib.optionals isPy3k [
    jeepney
    mss
  ];

  # recursive dependency on pyvirtualdisplay
  doCheck = false;
  format = "setuptools";
  pythonImportsCheck = [ "pyscreenshot" ];

  meta = {
    description = "Python screenshot";
    homepage = "https://github.com/ponty/pyscreenshot";
    license = lib.licenses.bsd3;
    maintainers = [ ];
  };
}

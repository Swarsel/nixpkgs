{
  lib,
  aioserial,
  buildPythonPackage,
  fetchPypi,
}:

buildPythonPackage rec {
  pname = "phone-modem";
  version = "0.1.2";

  src = fetchPypi {
    inherit version;
    hash = "sha256-7NahK9l67MdT/dDVXsq+y0Z4cZxZ/WUW2kPpE4Wz6j0=";
    pname = "phone_modem";
  };

  postPatch = ''
    substituteInPlace setup.py \
      --replace "aioserial==1.3.0" "aioserial"
  '';

  propagatedBuildInputs = [ aioserial ];
  # Project has no tests
  doCheck = false;
  format = "setuptools";
  pythonImportsCheck = [ "phone_modem" ];

  meta = {
    description = "Python module for receiving caller ID and call rejection";
    homepage = "https://github.com/tkdrob/phone_modem";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
}

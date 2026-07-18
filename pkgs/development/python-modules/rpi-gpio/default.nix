{
  lib,
  buildPythonPackage,
  fetchPypi,
}:

buildPythonPackage rec {
  pname = "rpi-gpio";
  version = "0.7.1";

  src = fetchPypi {
    inherit version;
    hash = "sha256-zWHEsDw3tiu6SlrP6phidJwzxhjgKV5+kKpHE/s3O3A=";
    pname = "RPi.GPIO";
  };

  # Tests disable because they do a platform check which requires running on a
  # Raspberry Pi
  doCheck = false;
  format = "setuptools";

  meta = {
    description = "Python module to control the GPIO on a Raspberry Pi";
    homepage = "https://sourceforge.net/p/raspberry-gpio-python";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ onny ];
    platforms = lib.platforms.linux;
  };
}

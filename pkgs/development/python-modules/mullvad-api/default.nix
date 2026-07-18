{
  lib,
  buildPythonPackage,
  fetchPypi,
  requests,
}:

buildPythonPackage rec {
  pname = "mullvad-api";
  version = "1.0.0";

  src = fetchPypi {
    inherit version;
    sha256 = "0r0hc2d6vky52hxdqxn37w0y42ddh1zal6zz2cvqlxamc53wbiv1";
    pname = "mullvad_api";
  };

  propagatedBuildInputs = [ requests ];
  # Project has no tests
  doCheck = false;
  format = "setuptools";
  pythonImportsCheck = [ "mullvad_api" ];

  meta = {
    description = "Python client for the Mullvad API";
    homepage = "https://github.com/meichthys/mullvad-api";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
}

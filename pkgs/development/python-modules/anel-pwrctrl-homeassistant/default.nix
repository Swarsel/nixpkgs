{
  lib,
  buildPythonPackage,
  fetchPypi,
}:
buildPythonPackage rec {
  pname = "anel-pwrctrl-homeassistant";
  version = "0.0.1.dev2";

  src = fetchPypi {
    inherit version;
    hash = "sha256-AcsnYD9CeGAarm5QdweUF6CUFwUywhfmU46NG8+Cm4s=";
    pname = "anel_pwrctrl-homeassistant";
  };

  # No tests
  doCheck = false;
  format = "setuptools";
  pythonImportsCheck = [ "anel_pwrctrl" ];

  meta = {
    description = "Discover and control ANEL NET-PwrCtrl devices";
    homepage = "https://github.com/mweinelt/anel-pwrctrl";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ jamiemagee ];
  };
}

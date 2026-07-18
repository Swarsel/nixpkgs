{
  lib,
  buildPythonPackage,
  fetchPypi,
}:

buildPythonPackage (finalAttrs: {
  pname = "setoptconf-tmp";
  version = "0.3.1";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    sha256 = "0y2pgpraa36wzlzkxigvmz80mqd3mzcc9wv2yx9bliqks7fhlj70";
  };

  # Base tests provided via PyPi are broken
  doCheck = false;
  format = "setuptools";

  meta = {
    description = "Module for retrieving program settings from various sources in a consistant method";
    homepage = "https://pypi.org/project/setoptconf-tmp";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      kamadorueda
    ];
  };
})

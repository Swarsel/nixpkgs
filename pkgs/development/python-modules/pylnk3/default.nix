{
  lib,
  buildPythonPackage,
  fetchPypi,
  invoke,
  pytest,
}:

buildPythonPackage rec {
  pname = "pylnk3";
  version = "0.4.3";

  src = fetchPypi {
    inherit version;
    hash = "sha256-+8X1ErWBOCwqTBHm3zeW+Zdbz9meP8oq/lMephs8SsI=";
    pname = "pylnk3";
  };

  propagatedBuildInputs = [
    pytest
    invoke
  ];

  # There are no tests in pylnk3.
  doCheck = false;
  format = "setuptools";
  pythonImportsCheck = [ "pylnk3" ];

  meta = {
    description = "Python library for reading and writing Windows shortcut files (.lnk)";
    homepage = "https://github.com/strayge/pylnk";
    license = with lib.licenses; [ lgpl3Only ];
    maintainers = with lib.maintainers; [ fedx-sudo ];
    mainProgram = "pylnk3";
  };
}

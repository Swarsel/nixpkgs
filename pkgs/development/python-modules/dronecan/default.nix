{
  lib,
  buildPythonPackage,
  fetchPypi,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "dronecan";
  version = "1.0.27";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-m6xfk/2pKfzbr0fu2GUjJnRcicoZDWzhrGJ6DDs2rBw=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  format = "setuptools";
  pythonImportsCheck = [ "dronecan" ];

  meta = {
    description = "Python implementation of the DroneCAN v1 protocol stack";

    longDescription = ''
      DroneCAN is a lightweight protocol designed for reliable communication in aerospace and robotic applications via CAN bus.
    '';

    homepage = "https://dronecan.github.io/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ kip93 ];
    mainProgram = "dronecan_bridge.py";
  };
}

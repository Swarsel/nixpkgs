{
  lib,
  fetchPypi,
  python3Packages,
}:
let
  pname = "hifiscan";
  version = "1.5.2";
  hash = "sha256-8eystqjNdDP2X9beogRcsa+Wqu50uMHZv59jdc5GjUc=";
in
python3Packages.buildPythonApplication {
  inherit pname version;

  src = fetchPypi {
    inherit pname version hash;
  };

  format = "setuptools";

  pythonPath = with python3Packages; [
    eventkit
    numpy
    sounddevice
    pyqt6
    pyqt6-sip
    pyqtgraph
  ];

  meta = {
    description = "Optimize the audio quality of your loudspeakers";
    homepage = "https://github.com/erdewit/HiFiScan";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ cab404 ];
    mainProgram = "hifiscan";
  };
}

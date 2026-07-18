{
  lib,
  fetchFromGitHub,
  alsa-lib,
  buildPythonPackage,
}:

buildPythonPackage rec {
  pname = "simpleaudio";
  version = "1.0.4";

  src = fetchFromGitHub {
    owner = "hamiltron";
    repo = "py-simple-audio";
    rev = version;
    sha256 = "12nypzb1m14yip4zrbzin5jc5awyp1d5md5y40g5anj4phb4hx1i";
  };

  patches = [ ./python312-fix.patch ];
  buildInputs = [ alsa-lib ];
  format = "setuptools";

  meta = {
    description = "Simple audio playback Python extension - cross-platform, asynchronous, dependency-free";
    homepage = "https://github.com/hamiltron/py-simple-audio";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ lucus16 ];
  };
}

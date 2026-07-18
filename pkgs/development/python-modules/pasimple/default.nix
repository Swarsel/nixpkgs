{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pulseaudio,
  setuptools,
}:

buildPythonPackage rec {
  pname = "pasimple";
  version = "0.0.2";

  src = fetchFromGitHub {
    owner = "henrikschnor";
    repo = "pasimple";
    rev = "v${version}";
    hash = "sha256-Z271FdBCqPFcQzVqGidL74nO85rO9clNvP4czAHmdEw=";
  };

  postPatch = ''
    substituteInPlace pasimple/pa_simple.py --replace \
      "_libpulse_simple = ctypes.CDLL('libpulse-simple.so.0')" \
      "_libpulse_simple = ctypes.CDLL('${lib.getLib pulseaudio}/lib/libpulse-simple.so.0')"
  '';

  nativeBuildInputs = [ setuptools ];
  # no tests
  doCheck = false;
  pyproject = true;

  pythonImportsCheck = [
    "pasimple"
    "pasimple.pa_simple"
  ];

  meta = {
    description = "Python wrapper for the \"PulseAudio simple API\". Supports playing and recording audio via PulseAudio and PipeWire";
    homepage = "https://github.com/henrikschnor/pasimple";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ hexa ];
  };
}

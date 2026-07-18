{
  lib,
  buildPythonPackage,
  fetchPypi,
}:

buildPythonPackage rec {
  pname = "midiutil";
  version = "1.2.1";

  src = fetchPypi {
    inherit version;
    sha256 = "02m9sqv36zrzgz5zg2w9qmz8snzlm27yg3ways2hgipgs4xriykr";
    pname = "MIDIUtil";
  };

  format = "setuptools";

  meta = {
    description = "Pure python library for creating multi-track MIDI files";
    homepage = "https://github.com/MarkCWirt/MIDIUtil";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}

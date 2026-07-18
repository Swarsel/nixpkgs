{
  lib,
  anyascii,
  buildPythonPackage,
  fetchPypi,
  inflect,
  nltk,
  numpy,
}:

buildPythonPackage rec {
  pname = "ttstokenizer";
  version = "1.1.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-akXiscw57CMp2JDdJq7wqeBeML41yLyFh7fTZwEBlVA=";
  };

  propagatedBuildInputs = [
    anyascii
    inflect
    nltk
    numpy
  ];

  # no tests
  doCheck = false;
  format = "setuptools";
  pythonImportsCheck = [ "ttstokenizer" ];

  meta = {
    description = "Tokenizer for Text to Speech (TTS) models";
    homepage = "https://pypi.org/project/ttstokenizer";
    license = with lib.licenses; [ asl20 ];
    maintainers = with lib.maintainers; [ happysalada ];
  };
}

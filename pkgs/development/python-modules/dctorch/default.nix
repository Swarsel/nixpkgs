{
  lib,
  buildPythonPackage,
  fetchPypi,
  numpy,
  poetry-core,
  scipy,
  torch,
}:

buildPythonPackage rec {
  pname = "dctorch";
  version = "0.1.2";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-TmfLAkiofrQNWYBhIlY4zafbZPgFftISCGloO/rlEG4=";
  };

  doCheck = false; # no tests
  build-system = [ poetry-core ];

  dependencies = [
    numpy
    scipy
    torch
  ];

  pyproject = true;
  pythonImportsCheck = [ "dctorch" ];
  pythonRelaxDeps = [ "numpy" ];

  meta = {
    description = "Fast discrete cosine transforms for pytorch";
    homepage = "https://pypi.org/project/dctorch/";
    license = lib.licenses.mit;
    teams = [ lib.teams.tts ];
  };
}

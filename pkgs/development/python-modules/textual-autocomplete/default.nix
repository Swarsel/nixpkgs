{
  lib,
  buildPythonPackage,
  fetchPypi,
  hatchling,
  poetry-core,
  textual,
  typing-extensions,
}:
buildPythonPackage rec {
  pname = "textual-autocomplete";
  version = "4.0.6";

  src = fetchPypi {
    inherit version;
    hash = "sha256-K6Lw12e+RIDsrLPksTDPBzQOAzw1APxCT+2RJdJ6RYY=";
    pname = "textual_autocomplete";
  };

  # No tests in the Pypi archive
  doCheck = false;

  build-system = [
    poetry-core
    hatchling
  ];

  dependencies = [
    textual
    typing-extensions
  ];

  pyproject = true;

  pythonImportsCheck = [
    "textual"
    "typing_extensions"
  ];

  meta = {
    description = "Python library that provides autocomplete capabilities to textual";
    homepage = "https://github.com/darrenburns/textual-autocomplete";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ jorikvanveen ];
  };
}

{
  lib,
  buildPythonPackage,
  fetchPypi,
  random2,
  six,
}:

buildPythonPackage rec {
  pname = "pysol-cards";
  version = "0.24.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-qYVJLagaoViN/AVtmnxsqD9mJUwLkPJa/GgqcHE9TUs=";
    pname = "pysol_cards";
  };

  propagatedBuildInputs = [
    six
    random2
  ];

  format = "setuptools";

  meta = {
    description = "Generates Solitaire deals";
    homepage = "https://github.com/shlomif/pysol_cards";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ mwolfe ];
    mainProgram = "pysol_cards";
  };
}

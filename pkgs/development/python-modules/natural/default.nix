{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  django,
  setuptools,
  six,
}:
buildPythonPackage rec {
  pname = "natural";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "tehmaze";
    repo = "natural";
    tag = version;
    hash = "sha256-DERFKDGVUPcjYAxiTYWgWkPp+Myd/9CNytQWgRya570=";
  };

  nativeCheckInputs = [ django ];
  build-system = [ setuptools ];
  dependencies = [ six ];
  pyproject = true;

  meta = {
    description = "Convert data to their natural (human-readable) format";
    homepage = "https://github.com/tehmaze/natural";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      sailord
      vinetos
    ];
  };
}

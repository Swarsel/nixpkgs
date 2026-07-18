{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  numpy,
  regex,
  requests,
  setuptools,
  tensorflow,
  toposort,
  tqdm,
}:

buildPythonPackage rec {
  pname = "gpt-2-simple";
  version = "0.8.1";

  src = fetchFromGitHub {
    owner = "minimaxir";
    repo = "gpt-2-simple";
    rev = "v${version}";
    hash = "sha256-WwD4sDcc28zXEOISJsq8e+rgaNrrgIy79Wa4J3E7Ovc=";
  };

  propagatedBuildInputs = [
    regex
    requests
    tqdm
    numpy
    toposort
    tensorflow
  ];

  doCheck = false; # no tests in upstream
  build-system = [ setuptools ];
  pyproject = true;

  meta = {
    description = "Easily retrain OpenAI's GPT-2 text-generating model on new texts";
    homepage = "https://github.com/minimaxir/gpt-2-simple";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}

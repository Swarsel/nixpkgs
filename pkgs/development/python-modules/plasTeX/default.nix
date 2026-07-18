{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  jinja2,
  pillow,
  # build-system
  setuptools,
  # dependencies
  typing-extensions,
  unidecode,
}:
buildPythonPackage {
  pname = "plasTeX";
  version = "3.1";

  src = fetchFromGitHub {
    owner = "plastex";
    repo = "plastex";
    rev = "193747318f7ebadd19eaaa1e9996da42a31a2697"; # The same as what is published on PyPi for version 3.1. See <https://github.com/plastex/plastex/issues/386>
    hash = "sha256-Muuin7n0aPOZwlUaB32pONy5eyIjtPNb4On5gC9wOcQ=";
  };

  build-system = [ setuptools ];

  dependencies = [
    typing-extensions
    pillow
    jinja2
    unidecode
  ];

  pyproject = true;

  meta = {
    description = "Python package to convert LaTeX markup to DOM";
    homepage = "https://plastex.github.io/plastex/";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ niklashh ];
  };
}

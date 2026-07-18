{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  isPy3k,
  # pythonPackages
  pylint-plugin-utils,
}:

buildPythonPackage rec {
  pname = "pylint-celery";
  version = "0.3";

  src = fetchFromGitHub {
    owner = "PyCQA";
    repo = "pylint-celery";
    rev = version;
    sha256 = "05fhwraq12c2724pn4py1bjzy5rmsrb1x68zck73nlp5icba6yap";
  };

  propagatedBuildInputs = [ pylint-plugin-utils ];
  # Testing requires a very old version of pylint, incompatible with other dependencies
  doCheck = false;
  disabled = !isPy3k;
  format = "setuptools";

  meta = {
    description = "Pylint plugin to analyze Celery applications";
    homepage = "https://github.com/PyCQA/pylint-celery";
    license = lib.licenses.gpl2;
    maintainers = with lib.maintainers; [ kamadorueda ];
  };
}

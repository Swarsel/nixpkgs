{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  funcy,
  ipython,
  jinja2,
  joblib,
  numpy,
  pandas,
  scikit-learn,
  scipy,
}:

buildPythonPackage rec {
  pname = "pyLDAvis";
  version = "3.4.1";

  src = fetchFromGitHub {
    owner = "bmabey";
    repo = "pyLDAvis";
    rev = version;
    sha256 = "sha256-WIQytds3PeU85l6ix2UUIwypjpM5rMZvQxiHx9BY91Y=";
  };

  propagatedBuildInputs = [
    funcy
    jinja2
    joblib
    ipython
    numpy
    pandas
    scikit-learn
    scipy
  ];

  format = "setuptools";

  pythonImportsCheck = [
    "pyLDAvis"
    "pyLDAvis.gensim_models"
  ];

  meta = {
    description = "Python library for interactive topic model visualization";
    homepage = "https://github.com/bmabey/pyLDAvis";
    license = lib.licenses.bsd3;
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
    platforms = lib.platforms.all;
  };
}

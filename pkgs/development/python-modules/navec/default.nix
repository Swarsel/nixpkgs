{
  lib,
  buildPythonPackage,
  fetchPypi,
  gensim,
  numpy,
  pytestCheckHook,
  razdel,
}:

buildPythonPackage rec {
  pname = "navec";
  version = "0.10.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-TyNHSxwnmvbGBfhOeHPofEfKWLDFOKP50w2QxgnJ/SE=";
  };

  propagatedBuildInputs = [
    numpy
    razdel
  ];

  nativeCheckInputs = [
    pytestCheckHook
    gensim
  ];

  # TODO: remove when gensim usage will be fixed in `navec`.
  disabledTests = [ "test_gensim" ];
  format = "setuptools";
  pythonImportsCheck = [ "navec" ];

  meta = {
    description = "Compact high quality word embeddings for Russian language";
    homepage = "https://github.com/natasha/navec";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ npatsakula ];
    mainProgram = "navec-train";
  };
}

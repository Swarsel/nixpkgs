{
  lib,
  buildPythonPackage,
  fetchPypi,
  mecab,
  setuptools-scm,
  swig,
}:

buildPythonPackage rec {
  pname = "mecab-python3";
  version = "1.0.12";

  src = fetchPypi {
    inherit version;
    hash = "sha256-mroeVu+A3ZcUfcv441CBR68Sn7Rs7A5DK4X5apvapLk=";
    pname = "mecab_python3";
  };

  nativeBuildInputs = [
    mecab # for mecab-config
    swig
    setuptools-scm
  ];

  buildInputs = [ mecab ];
  doCheck = false;
  format = "setuptools";
  pythonImportsCheck = [ "MeCab" ];

  meta = {
    description = "Python wrapper for mecab: Morphological Analysis engine";
    homepage = "https://github.com/SamuraiT/mecab-python3";
    changelog = "https://github.com/SamuraiT/mecab-python3/releases/tag/v${version}";

    license = with lib.licenses; [
      gpl2
      lgpl21
      bsd3
    ]; # any of the three
  };
}

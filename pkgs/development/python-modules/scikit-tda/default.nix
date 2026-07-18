{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cython,
  kmapper,
  matplotlib,
  numba,
  numpy,
  persim,
  pillow,
  pytest,
  ripser,
  scikit-learn,
  scipy,
  tadasets,
  umap-learn,
}:

buildPythonPackage rec {
  pname = "scikit-tda";
  version = "1.1.1";

  src = fetchFromGitHub {
    owner = "scikit-tda";
    repo = "scikit-tda";
    tag = "v${version}";
    sha256 = "sha256-sf7UxCFJZlIMGOgNFwoh/30U7xsBCZuJ3eumsjEelMc=";
  };

  propagatedBuildInputs = [
    numpy
    scipy
    scikit-learn
    matplotlib
    numba
    umap-learn
    cython
    ripser
    persim
    pillow
    kmapper
    tadasets
  ];

  # tests will be included in next release
  doCheck = false;
  nativeCheckInputs = [ pytest ];

  checkPhase = ''
    pytest test
  '';

  format = "setuptools";

  meta = {
    description = "Topological Data Analysis for humans";
    homepage = "https://github.com/scikit-tda/scikit-tda";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}

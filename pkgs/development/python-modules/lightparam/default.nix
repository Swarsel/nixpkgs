{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  ipython,
  ipywidgets,
  isPy3k,
  numpy,
  pyqt5,
}:

buildPythonPackage rec {
  pname = "lightparam";
  version = "0.4.6";

  src = fetchFromGitHub {
    owner = "portugueslab";
    repo = "lightparam";
    rev = "v${version}";
    sha256 = "13hlkvjcyz2lhvlfqyavja64jccbidshhs39sl4fibrn9iq34s3i";
  };

  propagatedBuildInputs = [
    ipython
    ipywidgets
    numpy
    pyqt5
  ];

  disabled = !isPy3k;
  format = "setuptools";
  pythonImportsCheck = [ "lightparam" ];

  meta = {
    description = "Another attempt at parameters in Python";
    homepage = "https://github.com/portugueslab/lightparam";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}

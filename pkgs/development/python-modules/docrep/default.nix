{
  lib,
  buildPythonPackage,
  fetchPypi,
  pytest,
  six,
}:

buildPythonPackage rec {
  pname = "docrep";
  version = "0.3.2";

  src = fetchPypi {
    inherit pname version;
    sha256 = "ed8a17e201abd829ef8da78a0b6f4d51fb99a4cbd0554adbed3309297f964314";
  };

  propagatedBuildInputs = [ six ];
  # tests not packaged with PyPi download
  doCheck = false;
  nativeCheckInputs = [ pytest ];

  checkPhase = ''
    py.test
  '';

  format = "setuptools";

  meta = {
    description = "Python package for docstring repetition";
    homepage = "https://github.com/Chilipp/docrep";
    license = lib.licenses.gpl2;
    maintainers = [ ];
  };
}

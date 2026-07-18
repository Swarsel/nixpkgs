{
  lib,
  buildPythonPackage,
  fetchPypi,
  pytest,
  tornado,
}:

buildPythonPackage rec {
  pname = "pytest-tornado";
  version = "0.8.1";

  src = fetchPypi {
    inherit pname version;
    sha256 = "1cgisd7lb9q2hf55558cbn5jfhv65vsgk46ykgidzf9kqcq1kymr";
  };

  buildInputs = [ pytest ];
  propagatedBuildInputs = [ tornado ];
  # package has no tests
  doCheck = false;
  format = "setuptools";

  meta = {
    description = "Py.test plugin providing fixtures and markers to simplify testing of asynchronous tornado applications";
    homepage = "https://github.com/eugeniy/pytest-tornado";
    license = lib.licenses.asl20;
  };
}

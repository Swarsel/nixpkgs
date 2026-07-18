{
  lib,
  buildPythonPackage,
  execnet,
  fetchPypi,
  pytest,
}:

buildPythonPackage rec {
  pname = "pytest-cache";
  version = "1.0";

  src = fetchPypi {
    inherit pname version;
    sha256 = "1a873fihw4rhshc722j4h6j7g3nj7xpgsna9hhg3zn6ksknnhx5y";
  };

  buildInputs = [ pytest ];
  propagatedBuildInputs = [ execnet ];
  # Too many failing tests. Are they maintained?
  doCheck = false;

  checkPhase = ''
    py.test
  '';

  format = "setuptools";

  meta = {
    description = "Pytest plugin with mechanisms for caching across test runs";
    homepage = "https://pypi.org/project/pytest-cache/";
    license = lib.licenses.mit;
  };
}

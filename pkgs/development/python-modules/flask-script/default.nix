{
  lib,
  buildPythonPackage,
  fetchPypi,
  flask,
  pytest,
}:

buildPythonPackage rec {
  pname = "flask-script";
  version = "2.0.6";

  src = fetchPypi {
    inherit version;
    hash = "sha256-ZCWWPZEFTPzBhYBxQccxSpxa1GMlkRvSTctIm9AWHGU=";
    pname = "Flask-Script";
  };

  propagatedBuildInputs = [ flask ];
  # No tests in archive
  doCheck = false;
  nativeCheckInputs = [ pytest ];
  format = "setuptools";

  meta = {
    description = "Scripting support for Flask";
    homepage = "https://github.com/smurfix/flask-script";
    license = lib.licenses.bsd3;
    maintainers = [ ];
  };
}

{
  lib,
  buildPythonPackage,
  fetchPypi,
  flask,
  pytestCheckHook,
  six,
}:

buildPythonPackage rec {
  pname = "flask-talisman";
  version = "1.1.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-xfSG9fVEIHKfhLPDhQzWP5bosDOpYpvuZsUk6jY3l/8=";
  };

  nativeBuildInputs = [ pytestCheckHook ];
  buildInputs = [ flask ];
  propagatedBuildInputs = [ six ];
  format = "setuptools";

  meta = {
    description = "HTTP security headers for Flask";
    homepage = "https://github.com/wntrblm/flask-talisman";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.symphorien ];
  };
}

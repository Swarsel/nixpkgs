{
  lib,
  buildPythonPackage,
  fetchPypi,
  lxml,
  setuptools,
}:

buildPythonPackage rec {
  pname = "dbus-deviation";
  version = "0.6.1";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-4GuI7+IjiF0nJd9Rz3ybe0Y9HG8E6knUaQh0MY0Ot6M=";
  };

  postPatch = ''
    substituteInPlace setup.py \
      --replace-fail "'setuptools_git >= 0.3'," "" \
      --replace-fail "'sphinx'," ""
  '';

  build-system = [ setuptools ];
  dependencies = [ lxml ];
  pyproject = true;
  pythonImportsCheck = [ "dbusdeviation" ];

  meta = {
    description = "Project for parsing D-Bus introspection XML and processing it in various ways";
    homepage = "https://tecnocode.co.uk/dbus-deviation/";
    license = lib.licenses.lgpl21Plus;
    maintainers = [ ];
  };
}

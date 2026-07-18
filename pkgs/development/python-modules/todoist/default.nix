{
  lib,
  buildPythonPackage,
  fetchPypi,
  requests,
}:

buildPythonPackage rec {
  pname = "todoist-python";
  version = "8.1.4";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-Rkg6eSLiQe8DZaVu2DEnlKLe8RLkRwKmpw+TaYj+lp0=";
  };

  propagatedBuildInputs = [ requests ];
  format = "setuptools";
  pythonImportsCheck = [ "todoist" ];

  meta = {
    description = "Official Todoist Python API library";
    homepage = "https://todoist-python.readthedocs.io/";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}

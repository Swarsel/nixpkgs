{
  lib,
  buildPythonPackage,
  fetchPypi,

  setuptools,
  six,
}:

buildPythonPackage rec {
  pname = "slpp";
  version = "1.2.3";

  src = fetchPypi {
    inherit version;
    hash = "sha256-If3ZMoNICQxxpdMnc+juaKq4rX7MMi9eDMAQEUy1Scg=";
    pname = "SLPP";
  };

  nativeBuildInputs = [ setuptools ];
  propagatedBuildInputs = [ six ];
  # No tests
  doCheck = false;
  pyproject = true;
  pythonImportsCheck = [ "slpp" ];

  meta = {
    description = "Simple lua-python parser";
    homepage = "https://github.com/SirAnthony/slpp";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}

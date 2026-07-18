{
  lib,
  buildPythonPackage,
  fetchPypi,
  matplotlib,
  setuptools,
}:

buildPythonPackage rec {
  pname = "SciencePlots";
  version = "2.1.1";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-2NGX40EPh+va0LnCZeqrWWCU+wgtlxI+g19rwygAq1Q=";
  };

  doCheck = false; # no tests
  build-system = [ setuptools ];
  dependencies = [ matplotlib ];
  pyproject = true;
  pythonImportsCheck = [ "scienceplots" ];

  meta = {
    description = "Matplotlib styles for scientific plotting";
    homepage = "https://github.com/garrettj403/SciencePlots";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ kilimnik ];
  };
}

{
  lib,
  buildPythonPackage,
  fetchPypi,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "geographiclib";
  version = "2.1";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-amVF5iYtDtNSLhPFFXE3GHl+N+2MZywxrXsknzcu8Qg=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "geographiclib" ];

  meta = {
    description = "Algorithms for geodesics (Karney, 2013) for solving the direct and inverse problems for an ellipsoid of revolution";
    homepage = "https://geographiclib.sourceforge.io";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}

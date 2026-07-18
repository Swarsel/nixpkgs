{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
}:

buildPythonPackage rec {
  pname = "types-mock";
  version = "5.2.0.20250924";

  src = fetchPypi {
    inherit version;
    hash = "sha256-lTGXVDtBg/ADY+jmJvbHq+oaP3pN1p0Zmt23CwG2uzU=";
    pname = "types_mock";
  };

  # Module has no tests
  doCheck = false;
  build-system = [ setuptools ];
  pyproject = true;

  meta = {
    description = "Type stub package for the mock package";
    homepage = "https://pypi.org/project/types-mock";
    license = lib.licenses.asl20;
    maintainers = [ ];
  };
}

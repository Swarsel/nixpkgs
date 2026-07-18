{
  lib,
  buildPythonPackage,
  fetchPypi,
  hatchling,
  pytestCheckHook,
  sortedcontainers,
  uv-dynamic-versioning,
}:

buildPythonPackage rec {
  pname = "intervaltree";
  version = "3.2.1";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-8/fouut911ufem0zzz7BACWYSo5m4wFtU35SEwxzz+I=";
  };

  nativeCheckInputs = [ pytestCheckHook ];

  preCheck = ''
    rm -rf build
  '';

  build-system = [
    hatchling
    uv-dynamic-versioning
  ];

  dependencies = [ sortedcontainers ];
  pyproject = true;

  meta = {
    description = "Editable interval tree data structure for Python 2 and 3";
    homepage = "https://github.com/chaimleib/intervaltree";
    license = [ lib.licenses.asl20 ];
    maintainers = [ lib.maintainers.bennofs ];
  };
}

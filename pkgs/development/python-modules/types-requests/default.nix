{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
  types-urllib3,
  urllib3,
}:

buildPythonPackage rec {
  pname = "types-requests";
  version = "2.32.4.20260107";

  src = fetchPypi {
    inherit version;
    hash = "sha256-AYoRrBWPgBv6hIV93sFlB1Djk9+KAEqKmuKpvsb8sk8=";
    pname = "types_requests";
  };

  # Module doesn't have tests
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    types-urllib3
    urllib3
  ];

  pyproject = true;
  pythonImportsCheck = [ "requests-stubs" ];

  meta = {
    description = "Typing stubs for requests";
    homepage = "https://github.com/python/typeshed";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
  };
}

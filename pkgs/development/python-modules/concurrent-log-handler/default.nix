{
  lib,
  buildPythonPackage,
  fetchPypi,
  hatchling,
  portalocker,
}:

buildPythonPackage rec {
  pname = "concurrent-log-handler";
  version = "0.9.29";

  src = fetchPypi {
    inherit version;
    hash = "sha256-vDenbT84TL9KmPaT69dwVD7cD0zVxqtrxw6eHX1YImU=";
    pname = "concurrent_log_handler";
  };

  doCheck = false; # upstream has no tests
  build-system = [ hatchling ];
  dependencies = [ portalocker ];
  pyproject = true;
  pythonImportsCheck = [ "concurrent_log_handler" ];

  meta = {
    description = "Python logging handler that allows multiple processes to safely write to the same log file concurrently";
    homepage = "https://github.com/Preston-Landers/concurrent-log-handler";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.bbjubjub ];
  };
}

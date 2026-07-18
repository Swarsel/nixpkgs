{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  crc16,
  setuptools,
}:

buildPythonPackage {
  pname = "pyoppleio-legacy";
  version = "1.0.8";

  src = fetchFromGitHub {
    owner = "tinysnake";
    repo = "python-oppleio-legacy";
    rev = "90c57f778554fcf3a00e42757d0e92caebcfd149";
    hash = "sha256-ccvMn/jQSkW11uMwG3P+i53NiDj+MNZgJYEkouQ1tvU=";
  };

  # Package has no tests
  doCheck = false;
  build-system = [ setuptools ];
  dependencies = [ crc16 ];
  pyproject = true;
  # Package has a runtime dependency on 'pycrc16' but we provide 'crc16'
  # They provide the same crc16 module
  pythonRemoveDeps = [ "pycrc16" ];

  meta = {
    description = "Python library for interfacing with Opple WiFi lights (legacy firmware support)";
    homepage = "https://github.com/tinysnake/python-oppleio-legacy";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.jamiemagee ];
  };
}

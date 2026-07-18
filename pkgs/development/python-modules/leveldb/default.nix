{
  lib,
  buildPythonPackage,
  fetchPypi,
  pythonAtLeast,
  setuptools,
}:

buildPythonPackage rec {
  pname = "leveldb";
  version = "0.201";

  src = fetchPypi {
    inherit pname version;
    sha256 = "1cffe776842917e09f073bd6ea5856c64136aebddbe51bd17ea29913472fecbf";
  };

  nativeBuildInputs = [ setuptools ];
  disabled = pythonAtLeast "3.12";
  pyproject = true;

  meta = {
    description = "Thread-safe Python bindings for LevelDB";
    homepage = "https://code.google.com/archive/p/py-leveldb/";
    license = lib.licenses.bsd3;
    maintainers = [ lib.maintainers.aanderse ];

    platforms = [
      "x86_64-linux"
      "i686-linux"
    ];
  };
}

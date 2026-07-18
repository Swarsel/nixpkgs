{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
}:

buildPythonPackage rec {
  pname = "macfsevents";
  version = "0.8.4";

  src = fetchPypi {
    inherit version;
    hash = "sha256-v3KD8dUXdkzNyBlbIWMdu6wcUGuSC/mo6ilWsxJ2Ucs=";
    pname = "MacFSEvents";
  };

  patches = [ ./fix-packaging.patch ];
  # PyEval_InitThreads is deprecated in Python 3.9, to be removed in Python 3.14
  # and breaks the build under clang 16.
  # https://github.com/malthe/macfsevents/issues/49
  env.NIX_CFLAGS_COMPILE = "-Wno-implicit-function-declaration";
  # Some tests fail under nix build directory
  doCheck = false;
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "fsevents" ];

  meta = {
    description = "Thread-based interface to file system observation primitives";
    homepage = "https://github.com/malthe/macfsevents";
    changelog = "https://github.com/malthe/macfsevents/blob/${version}/CHANGES.rst";
    license = lib.licenses.bsd2;
    maintainers = [ ];
    platforms = lib.platforms.darwin;
  };
}

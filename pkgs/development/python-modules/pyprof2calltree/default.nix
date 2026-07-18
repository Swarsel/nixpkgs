{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  setuptools,
}:

buildPythonPackage rec {
  pname = "pyprof2calltree";
  version = "1.4.5";

  # Fetch from GitHub because the PyPi packaged version does not
  # include all test files.
  src = fetchFromGitHub {
    owner = "pwaller";
    repo = "pyprof2calltree";
    tag = "v${version}";
    hash = "sha256-PrIYpvcoD+zVIoOdcON41JmqzpA5FyRKhI7rqDV8cSo=";
  };

  build-system = [ setuptools ];
  pyproject = true;

  meta = {
    description = "Help visualize profiling data from cProfile with kcachegrind and qcachegrind";
    homepage = "https://github.com/pwaller/pyprof2calltree";
    changelog = "https://github.com/pwaller/pyprof2calltree/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ sfrijters ];
    mainProgram = "pyprof2calltree";
  };
}
